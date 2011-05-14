require 'faraday'
require 'faraday_middleware'

class FlyingSphinx::API

  APIServer  = 'https://flying-sphinx.com'
  APIPath    = "/api/my/app"
  APIVersion = 2

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
    "#{APIPath}#{path}"
  end

  def api_headers
    {
      'Accept' => "application/vnd.flying-sphinx-v#{APIVersion}+json",
      'X-Flying-Sphinx-Token' => "#{identifier}:#{api_key}"
    }
  end

  def connection(connection_options = {})
    options = {
      :ssl     => {:verify => false},
      :url     => APIServer,
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
    
    puts "API Request: #{method} '#{path}'; params: #{data.inspect}"
    response = block.call
    puts "API Response: #{response.body.inspect}"
    return response
  end
  
  def log?
    ENV['VERBOSE_LOGGING'].present?
  end
end
