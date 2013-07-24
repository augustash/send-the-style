require "sinatra/base"
require "sinatra/namespace"
require "multi_json"
require "sass"
require "compass"

require "lib/sinatra/error_handling"

module Api
  class Base < ::Sinatra::Base
    register ::Sinatra::ErrorHandling
    register ::Sinatra::Namespace

    # global configuration elements
    configure do
      # do not log; handle these separately
      disable :dump_errors

      # do not capture; throw them up the stack
      enable :raise_errors

      # disable internal middleware for presenting errors as HTML
      disable :show_exceptions
    end

    # run before every request
    before do
      # set content type
      content_type :json
    end

    # global helper methods available to all namespaces
    helpers do
       # generate JSON from a hash
      def json(hash)
        MultiJson.dump(hash, pretty: true)
      end
    end
  end
end
