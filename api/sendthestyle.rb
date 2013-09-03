require "api/base"
require "sass"
require "compass"
require "faraday"

Compass.sass_engine_options[:load_paths].each do |path|
  Sass.load_paths << path
end

module Api
  class SendTheStyle < Base
    # allowed parameters
    VALID_PARAMS = %w[output_style relative_assets line_comments \
      disable_warnings images_dir http_images_path css_dir http_stylesheets_path \
      javascripts_dir http_javascripts_path fonts_dir http_fonts_path]

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
        # attempt to download the remote SASS file for processing
        style_file = params[:file]

        halt_400_bad_request("Invalid SASS file") \
          unless Faraday.head(style_file).status == 200

        response = Faraday.get(style_file)

        begin
          compass_params = whitelist(params, VALID_PARAMS)

          Compass.configuration do |config|
            compass_params.each do |key, value|
              config.send("#{key}=", value)
            end
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
