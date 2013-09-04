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
      ::Compass.add_project_configuration("config/compass.rb")
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
    namespace "/api", auth_via: :valid_key? do

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
        halt_400_bad_request("Invalid SASS file") \
          unless !params[:file].nil?
        style_file = params[:file]
        halt_400_bad_request("Invalid SASS file") \
          unless !params[:file].nil?
        halt_400_bad_request("Invalid SASS file") \
          unless Faraday.head(style_file).status == 200
        response = Faraday.get(style_file)

        begin
          # set any passed Compass options
          compass_params = whitelist(params, ::Sinatra::UtilitytHelper::VALID_PARAMS)
          ::Compass.configuration do |config|
            config.sass_options ||= {}
            compass_params.each do |key, value|
              if config.respond_to? key
                config.send "#{key}=", value
              else
                config.sass_options.merge! key.to_sym => value
              end
            end
          end

          # pass the downloaded SASS content to the renderer
          runtime_options = {}
          runtime_options[:style] = compass_params[:output_style].to_sym if compass_params[:output_style]
          runtime_options[:line_comments] = to_bool(compass_params[:line_comments]) if compass_params[:line_comments]
          runtime_options[:cache] = to_bool(compass_params[:cache]) if compass_params[:cache]

          css = send(:scss, response.body.chomp, ::Compass.sass_engine_options.merge!(runtime_options))
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
