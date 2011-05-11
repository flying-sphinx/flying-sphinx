require 'action_controller/dispatcher'

unless Rails.env.development? || Rails.env.test?
  ActionController::Dispatcher.to_prepare :flying_sphinx do
    config = FlyingSphinx::Configuration.new
  
    ThinkingSphinx::Configuration.instance.address = config.host
    ThinkingSphinx::Configuration.instance.port    = config.port
    ThinkingSphinx::Configuration.instance.configuration.searchd.client_key =
      config.client_key
  end

  ThinkingSphinx.database_adapter = FlyingSphinx::HerokuSharedAdapter
end
