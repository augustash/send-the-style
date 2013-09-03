require "sinatra/base"

module Sinatra
  module UtilitytHelper

    module Helpers
      def debug(post, time=Time.now)
        logfile = "send-the-style.log"
        if not File.exists?(logfile)
          File.new(logfile, "w")
        end
        File.open(logfile, "a" ) do |f|
          f.puts "==========================="
          f.puts ""
          f.puts "#{time}"
          f.puts ""
          f.puts "#{post}"
          f.puts ""
          f.puts "==========================="
        end
      end
    end

    def self.registered(app)
      # register module helpers
      app.helpers UtilitytHelper::Helpers
    end
  end

  register UtilitytHelper
end
