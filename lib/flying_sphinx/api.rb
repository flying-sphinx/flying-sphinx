require 'faraday'
require 'faraday_middleware'

class FlyingSphinx::API
  SERVER         = 'https://flying-sphinx.com'
  STAGING_SERVER = 'https://staging.flying-sphinx.com'
  PATH           = "/api/my/app"
  VERSION        = 3

  attr_reader :api_key, :identifier, :adapter

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

  def normalize_path(path)
    path = (path == '/' ? nil : "/#{path}")
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
      :url     => (ENV['STAGED_SPHINX_API_KEY'] ? STAGING_SERVER : SERVER),
      :headers => api_headers
    }

    Faraday.new(options) do |builder|
      builder.use Faraday::Request::UrlEncoded
      builder.use Faraday::Response::Rashify
      builder.use Faraday::Response::ParseJson
      builder.adapter(adapter)
    end
  end

  def log(method, path, data = {}, option = {}, &block)
    return block.call unless log?

    log_message "API Request: #{method} '#{path}'; params: #{data.inspect}"
    response = block.call
    log_message "API Response: #{response.body.inspect}"
    return response
  end

  def log_message(message)
    time = Time.zone ? Time.zone.now : Time.now.utc
    puts "[#{time.to_s}] #{message}"
  end

  def log?
    ENV['VERBOSE_LOGGING'] && ENV['VERBOSE_LOGGING'].length > 0
  end
end
