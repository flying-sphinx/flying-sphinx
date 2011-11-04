class FlyingSphinx::Railtie < Rails::Railtie
  rake_tasks do
    load File.expand_path('../tasks.rb', __FILE__)
  end

  initializer "flying_sphinx.set_sphinx_host_and_port" do |app|
    config = FlyingSphinx::Configuration.new

    ThinkingSphinx::Configuration.instance.searchd.address    = config.host
    ThinkingSphinx::Configuration.instance.searchd.port       = config.port
    ThinkingSphinx::Configuration.instance.searchd.client_key =
      config.client_key
  end if ENV['FLYING_SPHINX_IDENTIFIER'] || ENV['STAGED_SPHINX_IDENTIFIER']
end
