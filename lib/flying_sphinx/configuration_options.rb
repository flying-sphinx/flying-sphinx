class FlyingSphinx::ConfigurationOptions
  attr_reader :raw

  def initialize(raw = nil, version = nil)
    @raw     = raw || configuration.render
    @version = version || '2.2.3'
  end

  def settings
    @settings ||= FlyingSphinx::SettingFiles.new(indices).to_hash
  end

  def version
    version_defined? ? configuration.version : @version
  end

  private

  def configuration
    @configuration ||= ThinkingSphinx::Configuration.instance
  end

  def indices
    configuration.render
    configuration.indices
  end

  def version_defined?
    configuration.version.present?
  end
end
