class DigestRequestPattern < WebMock::RequestPattern
  def matches?(request_signature)
    request_signature.headers['Authorization'].present? && super
  end
end

module DigestHelpers
  def stub_digest_request(method, uri)
    stub_request(method, uri).
      with { |request| request.headers['Authorization'].blank? }.to_return(
        :status => 401,
        :headers => {'www-authenticate' => digest_authorization}
      )

    stub_request(method, uri).
      with { |request| request.headers['Authorization'].present? }
  end

  def a_digest_request(method, uri)
    DigestRequestPattern.new method, uri
  end

  private

  def digest_authorization
    %q{Digest realm="myrealm",
              qop="auth,auth-int",
              nonce="dcd98b7102dd2f0e8b11d0f600bfb0c093",
              opaque="5ccc069c403ebaf9f0171e9517f40e41"}
  end
end

RSpec.configure do |config|
  config.include DigestHelpers
end
