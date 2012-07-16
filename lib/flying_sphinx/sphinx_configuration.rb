class FlyingSphinx::SphinxConfiguration
  def initialize(thinking_sphinx = ThinkingSphinx::Configuration.instance)
    @thinking_sphinx = thinking_sphinx
  end

  def upload_to(api, tunnel = false)
    api.put '/',
      :configuration  => content,
      :sphinx_version => thinking_sphinx.version,
      :tunnel         => tunnel.to_s
  end

  private

  attr_reader :thinking_sphinx

  def content
    @content ||= begin
      thinking_sphinx.generate
      thinking_sphinx.configuration.render
    end
  end
end
