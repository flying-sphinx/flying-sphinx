class FlyingSphinx::SphinxConfiguration
  def initialize(configuration = ThinkingSphinx::Configuration.instance)
    @configuration = configuration
  end

  def upload_to(api)
    api.put '/',
      :configuration  => content,
      :sphinx_version => '2.0.4'
  end

  def upload_file_to(api, path)
    api.put '/',
      :configuration  => File.read(path),
      :sphinx_version => '2.0.4'
  end

  private

  def content
    @content ||= @configuration.render
  end
end
