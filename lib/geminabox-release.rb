require 'uri'
require 'net/http'

module GeminaboxRelease

  def self.host
    @host
  end

  def self.patch(options = {})
    if options[:host]
      @host = options[:host]
    elsif options[:use_config]
      require 'yaml'
      data = YAML.load_file(File.expand_path("~/.gem/geminabox"))
      if data.has_key?(:host)
        @host = data[:host]
      else
        raise "Please set your host in your geminabox config ~/.gem/geminabox"
      end
    else
      raise "Please provide a host to upload to."
    end


    Bundler::GemHelper.class_eval do

      alias_method :bundler_install, :install

      def install
        desc "Create tag #{version_tag} and build and push #{name}-#{version}.gem to #{GeminaboxRelease.host}"
        task 'inabox:release' => 'build' do
          release_inabox(built_gem_path)
        end
        bundler_install # call bunlders original install method
      end

      # same functionality as release_gem but calls inabox_push
      def release_inabox(built_gem_path=nil)
        guard_clean
        built_gem_path ||= build_gem
        tag_version { git_push } unless already_tagged?
        inabox_push(built_gem_path) if gem_push?
      end

      protected

      # pushes to geminabox
      def inabox_push(path)
        uri = URI.parse(GeminaboxRelease.host)
        username = uri.user
        password = uri.password
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
        post_body << "false"
        post_body << "\r\n--#{boundary}--\r\n\r\n"

        http = Net::HTTP.new(uri.host, uri.port)
        req = Net::HTTP::Post.new(uri.request_uri)
        req.body = post_body.join
        req.basic_auth(username, password) unless username.nil? || username.empty?
        req['Accept'] = 'text/plain'
        req["Content-Type"] = "multipart/form-data; boundary=#{boundary}"
        response = http.request(req)
        if response.code.to_i < 300
          Bundler.ui.confirm("Gem #{File.basename(path)} received and indexed.")
        else
          raise "Error (#{response.code} received)\n\n#{response.body}"
        end
      end

    end

  end
end