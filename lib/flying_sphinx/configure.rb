class FlyingSphinx::Configure
  def initialize(contents = nil)
    @contents = contents || FlyingSphinx.translator.sphinx_configuration
  end

  def call
    uploader.call :path => 'sphinx/config.conf', :contents => contents
    uploader.call :path => 'sphinx/version.txt', :contents => version

    settings.each_file_for_setting do |setting, file|
      uploader.call :prefix => setting, :file => file
    end
  end

  private

  attr_reader :contents

  def settings
    FlyingSphinx::SettingFiles.new
  end

  def thinking_sphinx
    ThinkingSphinx::Configuration.instance
  end

  def uploader
    @uploader ||= FlyingSphinx::Configure::Uploader.new
  end

  def version
    version_defined? ? thinking_sphinx.version : '2.1.4'
  end

  def version_defined?
    thinking_sphinx.respond_to?(:version) && thinking_sphinx.version.present?
  end
end

require 'flying_sphinx/configure/cache'
require 'flying_sphinx/configure/uploader'
