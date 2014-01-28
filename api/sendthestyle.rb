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
      # Drop the request completely if not made over SSL
      #
      before do
        if settings.environment == :production and !request.secure?
          halt
        end
      end

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
        halt_400_bad_request("Missing SASS file") \
          unless !params[:file].nil?
        style_file = params[:file]

        # build request
        connection = Faraday.new style_file, :ssl => {:verify => false}
        if !params[:auth_user].nil? and !params[:auth_pass].nil?
          puts "-- PARAMS: #{params}"
          connection.basic_auth params[:auth_user], params[:auth_pass]
        end

        # test for existence
        halt_400_bad_request("Unreadable SASS file") \
          unless connection.head(style_file).status == 200

        # fetch file
        response = connection.get

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
