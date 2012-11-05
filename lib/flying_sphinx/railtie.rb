class FlyingSphinx::Railtie < Rails::Railtie
  rake_tasks do
    load File.expand_path('../tasks.rb', __FILE__)
  end

  initializer "flying_sphinx.set_sphinx_host_and_port" do |app|
    config = FlyingSphinx::Configuration.new

    ThinkingSphinx::Configuration.instance.settings['connection_options'] = {
      :host     => config.host,
      :port     => 9306,
      :username => "#{config.identifier}#{config.api_key}"
    }
  end if ENV['FLYING_SPHINX_IDENTIFIER'] || ENV['STAGED_SPHINX_IDENTIFIER']
end
