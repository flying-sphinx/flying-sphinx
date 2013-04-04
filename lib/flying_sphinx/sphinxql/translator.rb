class FlyingSphinx::SphinxQL::Translator
  def initialize(configuration)
    thinking_sphinx.controller = FlyingSphinx::Controller.new configuration.api

    thinking_sphinx.settings['connection_options'] = {
      :host     => configuration.host,
      :port     => 9306,
      :username => configuration.username
    }
  end

  def sphinx_configuration
    @sphinx_configuration ||= thinking_sphinx.render
  end

  def sphinx_indices
    sphinx_configuration
    thinking_sphinx.indices
  end

  private

  def thinking_sphinx
    ThinkingSphinx::Configuration.instance
  end
end
