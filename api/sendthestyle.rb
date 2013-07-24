require "api/base"

module Api
  class SendTheStyle < Base
    get "/" do
      json({ message: "Welcome to Send-The-Styles!" })
    end

    ## handle 404 errors
    not_found do
      halt_404_not_found
    end
  end
end
