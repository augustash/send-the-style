require "sinatra/base"

module Sinatra
  module UtilitytHelper
    # allowed parameters
    VALID_PARAMS = %w[output_style relative_assets line_comments quiet cache \
      disable_warnings images_dir http_images_path css_dir http_stylesheets_path \
      javascripts_dir http_javascripts_path fonts_dir http_fonts_path]

    module Helpers
      def whitelist(params, valid)
        params.reject { |key,_| !valid.include? key }
      end

      def to_bool(value)
        return true if value == true || value =~ (/(true|t|yes|y|1)$/i)
        return false if value == false || value.nil? || value =~ (/(false|f|no|n|0)$/i)
        raise ArgumentError.new("invalid value for Boolean: \"#{value}\"")
      end

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
