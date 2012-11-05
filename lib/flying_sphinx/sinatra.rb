require 'flying_sphinx'

config = FlyingSphinx::Configuration.new

ThinkingSphinx::Configuration.instance.searchd.address    = config.host
ThinkingSphinx::Configuration.instance.searchd.port       = config.port

if ENV['DATABASE_URL'][/^mysql/].nil?
  ThinkingSphinx.database_adapter = FlyingSphinx::HerokuSharedAdapter
end
