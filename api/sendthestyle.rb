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

    ## handle 404 errors
    not_found do
      halt_404_not_found
    end

    ##
    # Homepage request; generates simple welcome message
    #
    # GET /
    #
    get "/?" do
      json({ message: "Welcome to Send-The-Styles!" })
    end

    ##
    # Create namespace to group all API methods
    #
    namespace "/api" do

      ##
      # Invalid request for API namespace alone
      #
      # GET /api(/)
      #
      get "/?" do
        halt_400_bad_request
      end

      ##
      # Compile passed SASS into CSS, respecting any passed options
      #
      # GET /api/compile?file=FQDN(&option=value)
      #
      get "/compile/?" do
        # attempt to download the remote SASS file for processing
        style_file = params[:file]
        halt_400_bad_request("Invalid SASS file") \
          unless Faraday.head(style_file).status == 200
        response = Faraday.get(style_file)

        begin
          # set any passed Compass options
          compass_params = whitelist(params, VALID_PARAMS)
          Compass.configuration do |config|
            compass_params.each do |key, value|
              config.send("#{key}=", value)
            end
          end

          # pass the downloaded SASS content to the renderer
          css = send(:scss, response.body.chomp)
        rescue Sass::SyntaxError => e
          halt_400_bad_request e.to_s
        end

        # return generated CSS
        json({
          code: "compile_success",
          css:  css
        })
      end
    end
  end
end
