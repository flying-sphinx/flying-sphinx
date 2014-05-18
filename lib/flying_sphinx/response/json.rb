class FlyingSphinx::Response::JSON < Faraday::Response::Middleware
  def on_complete(environment)
    return if environment[:request_headers]['Authorization'].nil?

    environment[:body] = MultiJson.load environment[:body]
  end
end
