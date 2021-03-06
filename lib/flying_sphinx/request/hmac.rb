class FlyingSphinx::Request::HMAC < Faraday::Middleware
  def initialize(app, identifier, api_key, service)
    super app

    @identifier = identifier
    @api_key    = api_key
    @service    = service
  end

  def call(environment)
    Ey::Hmac.sign! environment, identifier, api_key,
      :adapter => Ey::Hmac::Adapter::Faraday, :service => service

    app.call environment
  end

  private

  attr_reader :app, :identifier, :api_key, :service
end
