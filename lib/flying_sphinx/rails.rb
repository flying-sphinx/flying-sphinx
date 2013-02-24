require 'action_controller/dispatcher'

if ENV['FLYING_SPHINX_IDENTIFIER'] || ENV['STAGED_SPHINX_IDENTIFIER']
  ActionController::Dispatcher.to_prepare :flying_sphinx do
    if ThinkingSphinx::Configuration.instance.respond_to?(:settings)
      FlyingSphinx::SphinxQL.load
    else
      FlyingSphinx::Binary.load
    end
  end
end
