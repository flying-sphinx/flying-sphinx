class FlyingSphinx::Response::JSON < Faraday::Response::Middleware
  def on_complete(environment)
    environment[:body] = MultiJson.load environment[:body]
  end
end
