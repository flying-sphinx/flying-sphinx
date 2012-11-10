class FlyingSphinx::Railtie < Rails::Railtie
  rake_tasks do
    load File.expand_path('../tasks.rb', __FILE__)
  end

  initializer "flying_sphinx.set_sphinx_host_and_port" do |app|
    configuration = FlyingSphinx::Configuration.new
    controller    = FlyingSphinx::Controller.new configuration.api

    ThinkingSphinx::Configuration.instance.controller = controller
    ThinkingSphinx::Configuration.instance.settings['connection_options'] = {
      :host     => configuration.host,
      :port     => 9306,
      :username => configuration.username
    }
  end if ENV['FLYING_SPHINX_IDENTIFIER'] || ENV['STAGED_SPHINX_IDENTIFIER']
end
