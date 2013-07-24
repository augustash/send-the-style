require "sinatra/base"
require "sass"
require "compass"

# setup global app configurations
class SendTheStyle < Sinatra::Base
  configure :production, :development do
    enable :logging
  end

  before do
    # disable caching of all requests
    cache_control :no_cache, :max_age => 0
  end
end

# load the application
require "./app/sendthestyle"

# start the server if ruby file executed directly
SendTheStyle.run! if SendTheStyle.run?
