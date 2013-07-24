require 'securerandom'

module Sinatra
  module RandomPassword
    ##
    # Generates a random URL safe Base64-encoded password. Default is a
    # 12 character password
    #
    # @param  [Integer] n Random length
    # @return [String] Password of length 4/3 of n
    def passwd(n=9)
      SecureRandom.urlsafe_base64(n)
    end
  end

  helpers RandomPassword
end
