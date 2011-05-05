require 'faraday'
require 'faraday_middleware'

class FlyingSphinx::API

  APIServer = 'https://flying-sphinx.com'

  APIPath = "/heroku/app"

  attr_reader :api_key, :identifier, :adapter

  def initialize(identifier, api_key, adapter = Faraday.default_adapter)
    @api_key   = api_key
    @identifier = identifier
    @adapter = adapter
  end

  def get(path, data = {}, options = {})
    path = nil if path == '/'
    connection(:json => options[:json]).get do |req|
      req.url "#{APIPath}#{path}", data.merge(api_options)
    end
  end

  def post(path, data = {})
    path = nil if path == '/'
    connection.post("#{APIPath}#{path}", data.merge(api_options))
  end

  def put(path, data = {})
    path = nil if path == '/'
    connection.put("#{APIPath}/#{path}", data.merge(api_options))
  end

  private

  def api_options
    {
      :api_key   => api_key,
      :identifier => identifier
    }
  end

  def connection(connection_options = {})
    options = {
      :ssl => { :verify => false },
      :url => APIServer,
    }

    Faraday.new(options) do |builder|
      builder.use Faraday::Request::UrlEncoded
      builder.use Faraday::Response::Rashify
      builder.use Faraday::Response::ParseJson if connection_options[:json]
      builder.adapter(adapter)
    end
  end
end
