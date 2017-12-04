module MultipartHelpers
  def a_multipart_request(method, uri)
    MultipartRequestPattern.new method, uri
  end
end

class MultipartRequestPattern < WebMock::RequestPattern
  def with_file(&block)
    with { |request| block.call MultipartRequestToFile.call(request) }
  end
end

class MultipartRequestToFile
  def self.call(request)
    new(request).call
  end

  def initialize(request)
    @request = request
  end

  def call
    parsed["file"][:tempfile].read
  end

  private

  attr_reader :request

  def parsed
    if Rack::Multipart.respond_to? :extract_multipart
      Rack::Multipart.extract_multipart rack_request
    else
      Rack::Multipart.parse_multipart rack_env
    end
  end

  def rack_env
    transformed_headers.merge 'rack.input' => StringIO.new(request.body)
  end

  def rack_request
    Rack::Request.new rack_env
  end

  def transformed_headers
    request.headers.keys.inject({}) do |hash, key|
      hash[key.underscore.upcase] = request.headers[key]
      hash
    end
  end
end

RSpec.configure do |config|
  config.include MultipartHelpers
end
