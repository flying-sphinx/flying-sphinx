class FlyingSphinx::Railtie < Rails::Railtie
  rake_tasks do
    load File.expand_path('../tasks.rb', __FILE__)
  end
  
  initializer "flying_sphinx.set_sphinx_host_and_port" do |app|
    config = FlyingSphinx::Configuration.new
    
    ThinkingSphinx::Configuration.instance.address = config.host
    ThinkingSphinx::Configuration.instance.port    = config.port
    
    if ENV['DATABASE_URL'][/^mysql/].nil?
      ThinkingSphinx.database_adapter = FlyingSphinx::HerokuSharedAdapter
    end
  end unless Rails.env.development? || Rails.env.test?
end
