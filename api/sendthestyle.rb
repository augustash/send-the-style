require "api/base"
require "sass"
require "compass"
require "faraday"

Compass.sass_engine_options[:load_paths].each do |path|
  Sass.load_paths << path
end

module Api
  class SendTheStyle < Base
    # global configuration elements
    configure do
      Compass.add_project_configuration("config/compass.rb")
    end

    get "/?" do
      json({ message: "Welcome to Send-The-Styles!" })
    end

    ## handle 404 errors
    not_found do
      halt_404_not_found
    end

    namespace "/api" do
      get "/?" do
        halt_400_bad_request
      end

      get "/compile/?" do
        style_file = params[:file]
        http_images_path = params[:http_images_path]

        halt_400_bad_request("Invalid SASS file") \
          unless Faraday.head(style_file).status == 200

        response = Faraday.get(style_file)

        begin
          Compass.configuration do |config|
          # config.project_path     = File.dirname(__FILE__)
          # config.images_dir      = "sites/default/"
          # config.http_images_path = "http://static.mysite.com/img/"
            config.http_images_path = http_images_path
          end

          css = send(:scss, response.body.chomp, Compass.sass_engine_options.merge!({style: :expanded, line_comments: false}))
        rescue Sass::SyntaxError => e
          halt_400_bad_request e.to_s
        end

        json({
          code: "compile_success",
          css:  css
        })
      end
    end
  end
end
