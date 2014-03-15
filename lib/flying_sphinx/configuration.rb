class FlyingSphinx::Configuration
  def initialize(identifier = nil, api_key = nil)
    @identifier = identifier || identifier_from_env
    @api_key    = api_key    || api_key_from_env
  end

  def api
    @api ||= FlyingSphinx::API.new(identifier, api_key)
  end

  def client_key
    "#{identifier}:#{api_key}"
  end

  def host
    @host ||= response_body['server'] rescue host_from_env
  end

  def port
    @port ||= response_body['port'] rescue port_from_env
  end

  def username
    "#{identifier}#{api_key}"
  end

  private

  attr_reader :identifier, :api_key

  def change(initial, expected)
    api.post(initial)

    response = api.get('daemon')
    while response['status'] == initial
      sleep 0.5
      response = api.get('daemon')
    end

    response['status'] == expected
  end

  def response_body
    @response_body ||= api.get '/'
  end

  def identifier_from_env
    ENV['STAGED_SPHINX_IDENTIFIER'] || ENV['FLYING_SPHINX_IDENTIFIER']
  end

  def api_key_from_env
    ENV['STAGED_SPHINX_API_KEY'] || ENV['FLYING_SPHINX_API_KEY']
  end

  def host_from_env
    (ENV['STAGED_SPHINX_HOST'] || ENV['FLYING_SPHINX_HOST'] || '').dup
  end

  def port_from_env
    (ENV['STAGED_SPHINX_PORT'] || ENV['FLYING_SPHINX_PORT'] || '9306').dup
  end
end
