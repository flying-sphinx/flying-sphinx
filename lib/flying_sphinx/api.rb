class FlyingSphinx::API
  unless ENV['STAGED_SPHINX_API_KEY']
    SERVER     = 'https://flying-sphinx.com'
    PUSHER_KEY = 'a8518107ea8a18fe5559'
  else
    SERVER     = 'https://staging.flying-sphinx.com'
    PUSHER_KEY = 'c5602d4909b5144321ce'
  end

  PATH    = '/api/my/app'
  VERSION = 4

  attr_reader :api_key, :identifier

  def initialize(identifier, api_key, adapter = Faraday.default_adapter)
    @api_key    = api_key
    @identifier = identifier
    @adapter    = adapter
  end

  def get(path, data = {})
    connection.get do |request|
      request.url normalize_path(path), data
    end
  end

  def post(path, data = {})
    connection.post normalize_path(path), data
  end

  def put(path, data = {})
    connection.put normalize_path(path), data
  end

  private

  attr_reader :adapter

  def normalize_path(path)
    path = (path == '/' ? '' : "/#{path.gsub(/^\//, '')}")
    "#{PATH}#{path}"
  end

  def api_headers
    {
      'Accept' => "application/vnd.flying-sphinx-v#{VERSION}+json",
      'X-Flying-Sphinx-Token'   => "#{identifier}:#{api_key}",
      'X-Flying-Sphinx-Version' => FlyingSphinx::Version
    }
  end

  def connection(connection_options = {})
    options = {
      :ssl     => {:verify => false},
      :url     => SERVER,
      :headers => api_headers
    }

    Faraday.new(options) do |builder|
      # Built-in middleware
      builder.request :multipart
      builder.request :url_encoded

      # Local middleware
      builder.use FlyingSphinx::Response::Logger
      builder.use FlyingSphinx::Response::Invalid
      builder.use FlyingSphinx::Response::JSON

      builder.adapter adapter
    end
  end
end
