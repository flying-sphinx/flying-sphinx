require 'flying_sphinx'

if ENV['FLYING_SPHINX_IDENTIFIER'] || ENV['STAGED_SPHINX_IDENTIFIER']
  config = FlyingSphinx::Configuration.new

  ThinkingSphinx::Configuration.instance.address = config.host
  ThinkingSphinx::Configuration.instance.port    = config.port
  ThinkingSphinx::Configuration.instance.configuration.searchd.client_key =
    config.client_key

  if ENV['DATABASE_URL'][/^mysql/].nil?
    ThinkingSphinx.database_adapter = FlyingSphinx::HerokuSharedAdapter
  end
end
