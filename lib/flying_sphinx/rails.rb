require 'action_controller/dispatcher'

ActionController::Dispatcher.to_prepare :flying_sphinx do
  config = FlyingSphinx::Configuration.new
  
  ThinkingSphinx::Configuration.instance.address = config.host
  ThinkingSphinx::Configuration.instance.port    = config.port
  
  ThinkingSphinx.database_adapter = FlyingSphinx::HerokuSharedAdapter
end unless Rails.env.development? || Rails.env.test?
