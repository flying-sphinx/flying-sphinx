class FlyingSphinx::Response::Invalid < Faraday::Response::Middleware
  def on_complete(environment)
    return unless environment[:status] == 403

    raise 'Invalid Flying Sphinx credentials'
  end
end
