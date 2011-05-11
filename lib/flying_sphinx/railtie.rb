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
    
    ThinkingSphinx.database_adapter = FlyingSphinx::HerokuSharedAdapter
  end unless Rails.env.development? || Rails.env.test?
end
