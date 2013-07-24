require "sinatra/base"

module Sinatra
  module ErrorHandling

    module Helpers
      def halt_400_bad_request(message = nil)
        message ||= "Bad request"
        halt 400, json({ message: message })
      end

      def halt_401_unauthorized(message = nil)
        message ||= "Unauthorized"
        halt 401, json({ message: message })
      end

      def halt_403_forbidden(message = nil)
        message ||= "Forbidden"
        halt 403, json({ message: message })
      end

      def halt_404_not_found(message = nil)
        message ||= "Not found"
        halt 404, json({ message: message })
      end

      def halt_500_internal_server_error(message = nil)
        message ||= 'Internal server error'
        halt 500, json({ message: message })
      end
    end

    def self.registered(app)
      # register module helpers
      app.helpers ErrorHandling::Helpers

      # define specific error conditions
      app.error MultiJson::DecodeError do
        halt_400_bad_request("Could not parse JSON")
      end

      # catch-all errors
      app.error do
        # @todo - log exceptions
        halt_500_internal_server_error env['sinatra.error'].message if (ENV['RACK_ENV'] == 'development')
      end
    end
  end

  register ErrorHandling
end
