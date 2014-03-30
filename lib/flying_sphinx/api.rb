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
    log('GET', path, data) do
      connection.get do |request|
        request.url normalize_path(path), data
      end
    end
  end

  def post(path, data = {})
    log('POST', path, data) do
      connection.post normalize_path(path), data
    end
  end

  def put(path, data = {})
    log('PUT', path, data) do
      connection.put normalize_path(path), data
    end
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
      builder.request :multipart
      builder.request :url_encoded
      builder.adapter adapter
    end
  end

  def log(method, path, data = {}, option = {}, &block)
    FlyingSphinx.logger.debug "API Request: #{method} '#{path}'; params: #{data.inspect}"
    response = block.call
    FlyingSphinx.logger.debug "API Response: #{response.body.inspect}"
    raise 'Invalid Flying Sphinx credentials' if response.status == 403

    MultiJson.load response.body
  end
end
