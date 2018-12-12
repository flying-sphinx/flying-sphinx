require 'flying_sphinx'

if ENV['FLYING_SPHINX_IDENTIFIER'] || ENV['STAGED_SPHINX_IDENTIFIER']
  require 'flying_sphinx/commands'

  ThinkingSphinx.rake_interface = FlyingSphinx::RakeInterface
  load File.expand_path('../tasks.rb', __FILE__)

  configuration = FlyingSphinx::Configuration.new
  ThinkingSphinx::Configuration.instance.settings['connection_options'] = {
    :host     => configuration.host,
    :port     => 9306,
    :username => configuration.username
  }
end
