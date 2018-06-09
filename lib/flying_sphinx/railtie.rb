class FlyingSphinx::Railtie < Rails::Railtie
  rake_tasks do
    require 'flying_sphinx/commands'

    ThinkingSphinx.rake_interface = FlyingSphinx::RakeInterface

    load File.expand_path('../tasks.rb', __FILE__)
  end if ENV['FLYING_SPHINX_IDENTIFIER'] || ENV['STAGED_SPHINX_IDENTIFIER']

  initializer "flying_sphinx.set_sphinx_host_and_port" do |app|
    configuration = FlyingSphinx::Configuration.new

    ThinkingSphinx::Configuration.instance.settings['connection_options'] = {
      :host     => configuration.host,
      :port     => 9306,
      :username => configuration.username
    }
  end if ENV['FLYING_SPHINX_IDENTIFIER'] || ENV['STAGED_SPHINX_IDENTIFIER']
end
