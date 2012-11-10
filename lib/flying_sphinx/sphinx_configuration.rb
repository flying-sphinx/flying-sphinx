class FlyingSphinx::SphinxConfiguration
  def initialize(thinking_sphinx = nil)
    @thinking_sphinx = thinking_sphinx
  end

  def upload_to(api)
    @thinking_sphinx ||= ThinkingSphinx::Configuration.instance

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
    @content ||= @thinking_sphinx.render
  end
end
