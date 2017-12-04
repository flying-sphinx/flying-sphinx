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
    Rack::Multipart.extract_multipart rack_request
  end

  def rack_env
    transformed_headers.merge 'rack.input' => StringIO.new(request.body)
  end

  def rack_request
    Rack::Request.new rack_env
  end

  def transformed_headers
    request.headers.transform_keys { |key| key.underscore.upcase }
  end
end

RSpec.configure do |config|
  config.include MultipartHelpers
end
