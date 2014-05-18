class FlyingSphinx::API
  unless ENV['STAGED_SPHINX_API_KEY']
    SERVER     = 'https://flying-sphinx.com'
    PUSHER_KEY = 'a8518107ea8a18fe5559'
  else
    SERVER     = 'https://staging.flying-sphinx.com'
    PUSHER_KEY = 'c5602d4909b5144321ce'
  end

  PATH    = '/api/my/app'
  VERSION = 5

  attr_reader :api_key, :identifier

  def initialize(identifier, api_key)
    @api_key    = api_key
    @identifier = identifier
  end

  def get(path, data = {})
    connection.get "#{PATH}#{path}", data
  end

  def post(path, data = {})
    connection.post "#{PATH}#{path}", data
  end

  private

  def connection_options
    {
      :ssl     => {:verify => false},
      :url     => SERVER,
      :headers => api_headers
    }
  end

  def api_headers
    {
      'Accept' => "application/vnd.flying-sphinx-v#{VERSION}+json",
      'X-Flying-Sphinx-Token'   => "#{identifier}:#{api_key}",
      'X-Flying-Sphinx-Version' => FlyingSphinx::Version
    }
  end

  def connection
    @connection ||= Faraday.new(connection_options) do |builder|
      # Built-in middleware
      builder.request :url_encoded

      # Local middleware
      builder.use FlyingSphinx::Response::Logger
      builder.use FlyingSphinx::Response::Invalid
      builder.use FlyingSphinx::Response::JSON
    end
  end
end
