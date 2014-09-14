require 'uri'
require 'net/http'

module GeminaboxRelease

  def self.host
    @host
  end

  def self.patch(host)
    @host = host

    Bundler::GemHelper.class_eval do
      def install
        built_gem_path = nil

        desc "Build #{name}-#{version}.gem into the pkg directory."
        task 'build' do
          built_gem_path = build_gem
        end

        desc "Build and install #{name}-#{version}.gem into system gems."
        task 'install' => 'build' do
          install_gem(built_gem_path)
        end

        desc "Create tag #{version_tag} and build and push #{name}-#{version}.gem to #{GeminaboxRelease.host}"
        task 'release:inabox' => 'build' do
          release_gem(built_gem_path)
        end

        Bundler::GemHelper.instance = self
      end

      def rubygem_push(path)
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
          puts response.body
        else
          raise "Error (#{response.code} received)\n\n#{response.body}"
        end
      end

    end

  end
end