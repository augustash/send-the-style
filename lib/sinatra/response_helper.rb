require "sinatra/base"

module Sinatra
  module ResponseHelper

    module Helpers
      def json(hash)
        MultiJson.dump(hash, pretty: true)
      end

      def json_error(status, content)
        halt status, json(content)
      end

      def halt_400_bad_request(message = nil, code = nil)
        message ||= "Bad request"
        code    ||= "bad_request"
        json_error 400, { code: code, message: message }
      end

      def halt_401_unauthorized(message = nil, code = nil)
        message ||= "Unauthorized"
        code    ||= "unauthorized"
        json_error 401, { code: code, message: message }
      end

      def halt_403_forbidden(message = nil, code = nil)
        message ||= "Forbidden"
        code    ||= "forbidden"
        json_error 403, { code: code, message: message }
      end

      def halt_404_not_found(message = nil, code = nil)
        message ||= "Not found"
        code    ||= "not_found"
        json_error 404, { code: code, message: message }
      end

      def halt_422_unprocessable(message = nil, code = nil)
        message ||= "Unprocessable Entity"
        code    ||= "unprocessable_entity"
        json_error 422, { code: code, message: message }
      end

      def halt_500_internal_server_error(message = nil, code = nil)
        message ||= 'Internal server error'
        code    ||= "server_error"
        json_error 500, { code: code, message: message }
      end
    end

    def self.registered(app)
      # register module helpers
      app.helpers ResponseHelper::Helpers

      # define specific error conditions
      app.error MultiJson::LoadError do
        halt_400_bad_request("Could not parse JSON")
      end

      # catch-all errors
      app.error do
        # @todo - log exceptions
        halt_500_internal_server_error env['sinatra.error'].message if (ENV['RACK_ENV'] == 'development')
      end
    end
  end

  register ResponseHelper
end
