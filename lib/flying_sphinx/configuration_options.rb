class FlyingSphinx::ConfigurationOptions
  attr_reader :raw, :engine

  def initialize(raw = nil, version = nil)
    @raw     = raw || configuration.render
    @version = version || '2.2.11'
    @engine  = configuration.settings["engine"] || "sphinx"
  end

  def settings
    @settings ||= begin
      configuration.render
      FlyingSphinx::SettingFiles.new(configuration).to_hash
    end
  end

  def version
    version_defined? ? configuration.version : @version
  end

  private

  def configuration
    @configuration ||= ThinkingSphinx::Configuration.instance
  end

  def version_defined?
    configuration.version.present?
  end
end
