class FlyingSphinx::Railtie < Rails::Railtie
  rake_tasks do
    next unless FlyingSphinx::Railtie.remote_sphinx?

    require 'flying_sphinx/commands'

    ThinkingSphinx.rake_interface = FlyingSphinx::RakeInterface

    load File.expand_path('../tasks.rb', __FILE__)
  end

  initializer "flying_sphinx.set_sphinx_host_and_port" do |app|
    FlyingSphinx::Railtie.set_up_remote_connection
  end

  config.to_prepare do
    FlyingSphinx::Railtie.set_up_remote_connection
  end

  def self.remote_sphinx?
    ENV['FLYING_SPHINX_IDENTIFIER'] || ENV['STAGED_SPHINX_IDENTIFIER']
  end

  def self.set_up_remote_connection
    return unless remote_sphinx?

    configuration = FlyingSphinx::Configuration.new

    ThinkingSphinx::Configuration.instance.settings['connection_options'] = {
      :host     => configuration.host,
      :port     => 9306,
      :username => configuration.username
    }
  end
end
