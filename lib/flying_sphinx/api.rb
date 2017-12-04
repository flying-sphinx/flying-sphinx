class FlyingSphinx::API
  unless ENV['STAGED_SPHINX_API_KEY']
    SERVER     = 'https://flying-sphinx.com'
    PUSHER_KEY = 'a8518107ea8a18fe5559'
  else
    SERVER     = 'https://staging.flying-sphinx.com'
    PUSHER_KEY = 'c5602d4909b5144321ce'
  end

  PATH    = '/api/my/v5'
  HEADERS = {'X-Flying-Sphinx-Version' => FlyingSphinx::Version}

  attr_reader :api_key, :identifier

  def initialize(identifier, api_key, adapter = Faraday.default_adapter)
    @api_key    = api_key
    @identifier = identifier
    @adapter    = adapter
  end

  def get(path, data = {})
    connection.get { |request| request.url normalize_path(path), data }.body
  end

  def post(path, data = {})
    connection.post(normalize_path(path), data).body
  end

  private

  attr_reader :adapter

  def normalize_path(path)
    path = (path == '/' ? '' : "/#{path.gsub(/^\//, '')}")
    "#{PATH}#{path}"
  end

  def connection(connection_options = {})
    options = {
      :ssl     => {:verify => false},
      :url     => SERVER,
      :headers => HEADERS
    }

    Faraday.new(options) do |builder|
      # Built-in middleware
      builder.request :url_encoded

      # Local middleware
      builder.use FlyingSphinx::Request::HMAC, identifier, api_key, 'Thebes'
      builder.use FlyingSphinx::Response::Logger
      builder.use FlyingSphinx::Response::Invalid
      builder.use FlyingSphinx::Response::JSON

      builder.adapter adapter
    end
  end
end
