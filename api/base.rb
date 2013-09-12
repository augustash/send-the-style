require "sinatra/base"
require "sinatra/reloader"
require "sinatra/namespace"
require "multi_json"

require "lib/sinatra/response_helper"
require "lib/sinatra/utility_helper"

module Api
  class Base < ::Sinatra::Base
    register ::Sinatra::ResponseHelper
    register ::Sinatra::UtilitytHelper
    register ::Sinatra::Namespace

    # simple authentication
    register do
      def auth_via(name)
        condition do
          halt_401_unauthorized unless send(name) == true
        end
      end
    end

    # global configuration elements
    configure do
      # do not log; handle these separately
      disable :dump_errors

      # do not capture; throw them up the stack
      enable :raise_errors

      # disable internal middleware for presenting errors as HTML
      disable :show_exceptions
    end

    # we want to log things
    configure :production, :development do
      enable :logging
    end

    # development environment config
    configure :development do
      register Sinatra::Reloader
    end

    # run before every request
    before do
      # set content type
      content_type :json
    end

    # global helper methods available to all namespaces
    helpers do
      # check for valid API key
      def valid_key?
        # check for valid key in headers
        @auth ||=  Rack::Auth::Basic::Request.new(request.env)
        authed = @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [ENV['API_KEY'], ENV['API_PASSWORD']]

        # check secondly for valid key as a parameter
        if !authed and !request.params['apikey'].nil?
          authed = request.params['apikey'] == ENV['API_KEY']
        end

        authed
      end
    end
  end
end
