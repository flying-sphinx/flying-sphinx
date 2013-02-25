require 'flying_sphinx'

configuration = FlyingSphinx::Configuration.new
controller    = FlyingSphinx::Controller.new configuration.api

ThinkingSphinx::Configuration.instance.controller = controller
ThinkingSphinx::Configuration.instance.settings['connection_options'] = {
  :host     => configuration.host,
  :port     => 9306,
  :username => configuration.username
}
