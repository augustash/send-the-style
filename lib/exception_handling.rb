# exception handler middleware
class ExceptionHandling
  def initialize(app)
    @app = app
  end

  def call(env)
    begin
      @app.call env
    rescue => ex
      env['rack.errors'].puts ex
      env['rack.errors'].puts ex.backtrace.join("\n")
      env['rack.errors'].flush

      hash = { :message => ex.to_s }
      hash[:backtrace] = ex.backtrace if ENV['RACK_ENV'] == 'development'

      [500, {'Content-Type' => 'application/json'}, [MultiJson.dump(hash, pretty: true)]]
    end
  end
end
