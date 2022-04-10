class FlyingSphinx::Response::Logger < Faraday::Middleware
  extend Forwardable

  def call(environment)
    debug "API Request: #{environment[:method]} #{environment[:url]}"
    debug "API Body:    #{environment[:body].inspect}"

    super
  end

  def on_complete(environment)
    debug "API Status:   #{environment[:status]}"
    debug "API Response: #{environment[:body].inspect}"
  end

  private

  def_delegators :logger, :debug

  def logger
    FlyingSphinx.logger
  end
end
