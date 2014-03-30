class FlyingSphinx::ConfigurationOptions
  def to_hash
    {:sphinx_version => version, :configuration => gzipped_files_hash}
  end

  private

  def configuration
    @configuration ||= ThinkingSphinx::Configuration.instance
  end

  def files_hash
    FlyingSphinx::SettingFiles.new.to_hash.merge(
      'sphinx' => FlyingSphinx.translator.sphinx_configuration
    )
  end

  def gzipped_files_hash
    FlyingSphinx::GzippedHash.new(files_hash).to_gzipped_hash
  end

  def version
    version_defined? ? configuration.version : '2.0.4'
  end

  def version_defined?
    configuration.respond_to?(:version) && configuration.version.present?
  end
end
