class FlyingSphinx::Response::Invalid < Faraday::Middleware
  def on_complete(environment)
    return unless environment[:status] == 403

    raise FlyingSphinx::Error, 'Invalid Flying Sphinx credentials'
  end
end
