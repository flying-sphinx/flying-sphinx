require 'action_controller/dispatcher'

if ENV['FLYING_SPHINX_IDENTIFIER']
  ActionController::Dispatcher.to_prepare :flying_sphinx do
    config = FlyingSphinx::Configuration.new

    ThinkingSphinx::Configuration.instance.address = config.host
    ThinkingSphinx::Configuration.instance.port    = config.port
    ThinkingSphinx::Configuration.instance.configuration.searchd.client_key =
      config.client_key
  end

  if ENV['DATABASE_URL'] && ENV['DATABASE_URL'][/^mysql/].nil?
    ThinkingSphinx.database_adapter = FlyingSphinx::HerokuSharedAdapter
  end
end
