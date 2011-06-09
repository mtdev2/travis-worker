require 'uri'

module Travis
  module Reporter
    class Http < Base
      protected
        def active?
          !!@active
        end

        def message(type, data)
          path = "/builds/#{build.id}#{'/log' if data.delete(:incremental)}"
          messages.add(type, path, :_method => :put, :build => data)
        end

        def deliver_message(message)
          @active = true
          connection.post(message.target, message.data)
          @active = false
        end

        def connection
          Faraday.new(host) do |connection|
            connection.basic_auth(uri.user, uri.password)
          end
        end

        def host
          @host ||= config.url || 'http://127.0.0.1'
        end

        def uri
          @uri ||= URI.parse(host)
        end

        def config
          @config ||= Travis::Worker.config.reporter.http || Hashie::Mash.new
        end
    end
  end
end

