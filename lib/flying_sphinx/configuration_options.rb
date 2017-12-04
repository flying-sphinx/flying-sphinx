class FlyingSphinx::ConfigurationOptions
  attr_reader :raw

  def initialize(raw = nil, version = nil)
    @raw     = raw || FlyingSphinx.translator.sphinx_configuration
    @version = version || '2.2.3'
  end

  def settings
    @settings ||= FlyingSphinx::SettingFiles.new.to_hash
  end

  def version
    version_defined? ? configuration.version : @version
  end

  private

  def configuration
    @configuration ||= ThinkingSphinx::Configuration.instance
  end

  def version_defined?
    configuration.respond_to?(:version) && configuration.version.present?
  end
end
