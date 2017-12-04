class HMACRequestPattern < WebMock::RequestPattern
  def matches?(request_signature)
    request_signature.headers['Authorization'].present? && super
  end
end

module HMACHelpers
  def stub_hmac_request(method, uri)
    stub_request(method, uri).with { |request|
      request.headers['Authorization'].present?
    }
  end

  def a_hmac_request(method, uri)
    HMACRequestPattern.new method, uri
  end

  private
end

RSpec.configure do |config|
  config.include HMACHelpers
end
