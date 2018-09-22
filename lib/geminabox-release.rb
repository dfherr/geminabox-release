require 'uri'
require 'net/https'
require 'bundler'

module GeminaboxRelease

  class GeminaboxRelease::Error < StandardError;  end
  class GeminaboxRelease::NoHost < GeminaboxRelease::Error
    def initialize(msg = "")
      if msg.empty?
        msg = "Please provide a host to upload to, via :host or :use_config option."
      end
      super(msg)
    end
  end

  class GeminaboxRelease::NoConfigFile < GeminaboxRelease::Error
    def initialize(msg = "")
      if msg.empty?
        msg = "Please provide a geminabox config file in ~/.gem/geminabox to use :use_config option.\n"
        msg += "The config file should be YAML with an host entry, e.g.\n \":host: http://your.host.tld:optional-port\""
      end
      super(msg)
    end
  end

  class GeminaboxRelease::InvalidConfig < GeminaboxRelease::Error
    def initialize(msg = "")
      if msg.empty?
        msg = "Please set your host in your geminabox config (in ~/.gem/geminabox).\n"
        msg += "The config file should be YAML with an host entry, e.g.\n \":host: http://your.host.tld:optional-port\""
      end
      super(msg)
    end
  end

  def self.host
    @config[:host]
  end

  def self.username
    @config[:username]
  end

  def self.password
    @config[:password]
  end

  def self.ssl_dont_verify
    @config[:ssl_dont_verify]
  end

  # extract credentials from a) our options and b) the given URI
  def self.credentials(uri)
    username = GeminaboxRelease.username
    password = GeminaboxRelease.password

    unless uri.user.nil? || uri.user.empty?
      username = URI.unescape uri.user
      password = URI.unescape uri.password || ""
    end
    [username, password]
  end

  def self.patch(options = {})
    begin
    attribute_options = [:host, :username, :password, :ssl_dont_verify]
    @config = {}
    # read defaults from config file, if requested
    if options[:use_config]
      require 'yaml'
      raise GeminaboxRelease::NoConfigFile unless File.exist?(File.expand_path("~/.gem/geminabox"))
      data = YAML.load_file(File.expand_path("~/.gem/geminabox"))
      attribute_options.each { |k| @config[k] = data[k] if data.has_key?(k) }
    end
    # overwrite defaults with concrete values, if specified
    @config.merge! options.select { |k,v| attribute_options.include? k }

    # sanity checks
    raise GeminaboxRelease::NoHost if @config[:host].nil?

    Bundler::GemHelper.class_eval do

      alias_method :bundler_install, :install

      def install

        desc "Create tag #{version_tag} and build and push #{name}-#{version}.gem to #{GeminaboxRelease.host}"
        task 'inabox:release' do
          release_inabox
        end

        desc "Build & push #{name}-#{version}.gem to #{GeminaboxRelease.host}"
        task 'inabox:push' do
          push_inabox_gem
        end

        desc "Build & push #{name}-#{version}.gem overwriting same version to #{GeminaboxRelease.host}"
        task 'inabox:forcepush' do
          push_inabox_gem(true)
        end

        bundler_install # call bunlders original install method
      end

      # same functionality as release_gem but calls inabox_push
      def release_inabox
        guard_clean
        built_gem_path = build_gem
        tag_version { git_push } unless already_tagged?
        inabox_push(built_gem_path) if gem_push?
      end

      def push_inabox_gem(force = false)
        built_gem_path = build_gem
        inabox_push(built_gem_path, force)
      end

      protected

      # pushes to geminabox
      def inabox_push(path, force = false)
        uri = URI.parse(GeminaboxRelease.host)

        username, password = GeminaboxRelease.credentials(uri)

        uri.path = uri.path + "/" unless uri.path.end_with?("/")
        uri.path += "upload"

        #############
        # prepare multipart file post
        #############

        # Token used to terminate the file in the post body. Make sure it is not
        # present in the file you're uploading.
        boundary = "AaB03x" + "BOUNDARY" + "x30BaA"

        post_body = []
        post_body << "--#{boundary}\r\n"
        post_body << "Content-Disposition: form-data; name=\"file\"; filename=\"#{File.basename(path)}\"\r\n"
        post_body << "Content-Type: application/octet-stream\r\n"
        post_body << "\r\n"
        post_body << File.binread(path)
        post_body << "\r\n--#{boundary}\r\n"
        post_body << "Content-Disposition: form-data; name=\"overwrite\"\r\n"
        post_body << "\r\n"
        post_body << "#{force}"
        post_body << "\r\n--#{boundary}--\r\n\r\n"

        http = Net::HTTP.new(uri.host, uri.port)
        if uri.scheme == 'https'
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE if GeminaboxRelease.ssl_dont_verify
        end
        req = Net::HTTP::Post.new(uri.request_uri)
        req.body = post_body.join
        req.basic_auth(username, password) unless username.nil? || username.empty?
        req['Accept'] = 'text/plain'
        req["Content-Type"] = "multipart/form-data; boundary=#{boundary}"
        response = http.request(req)
        if response.code.to_i < 300
          if response.body.start_with?("Gem #{File.basename(path)} received and indexed")
            Bundler.ui.confirm("Gem #{File.basename(path)} received and indexed.")
          else
            Bundler.ui.error "Geminabox error received\n\n#{response.body}"
            exit 1
          end
        else
          raise "Error (#{response.code} received)\n\n#{response.body}"
        end
      end

    end  # end of class_eval

    # initialize patched gem tasks
    require 'bundler/gem_tasks'

    # delete the rake release task if option is enabled
    if options[:remove_release]
      Rake::TaskManager.class_eval do
        def remove_task(task_name)
          @tasks.delete(task_name.to_s)
        end
      end
      Rake.application.remove_task('release')
    end

  end
  rescue GeminaboxRelease::Error => e
    # \033[31m RED, \033[1m BOLD, \033[22m BOLD OFF, \033[0m COLOR OFF
    STDERR.puts "\033[31mGeminaboxRelease Exception: \033[1m#{e.class.to_s}\033[22m\033[0m"
    STDERR.puts "\033[31m#{e.message}\033[0m"
  end

end
