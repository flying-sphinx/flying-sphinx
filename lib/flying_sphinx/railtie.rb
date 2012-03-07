class FlyingSphinx::Railtie < Rails::Railtie
  rake_tasks do
    load File.expand_path('../tasks.rb', __FILE__)
  end

  initializer "flying_sphinx.set_sphinx_host_and_port" do |app|
    config = FlyingSphinx::Configuration.new

    ThinkingSphinx::Configuration.instance.address = config.host
    ThinkingSphinx::Configuration.instance.port    = config.port
    ThinkingSphinx::Configuration.instance.configuration.searchd.client_key =
      config.client_key

    if ENV['DATABASE_URL'] && ENV['DATABASE_URL'][/^mysql/].nil?
      ThinkingSphinx.database_adapter = FlyingSphinx::HerokuSharedAdapter
    end
  end if ENV['FLYING_SPHINX_IDENTIFIER'] || ENV['STAGED_SPHINX_IDENTIFIER']
end
