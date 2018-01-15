require 'logger'

module FlyingSphinx
  module Request; end
  module Response; end
  module Translators; end

  Error = Class.new StandardError

  @logger       = Logger.new(STDOUT)
  @logger.level = Logger::INFO
  if ENV['VERBOSE_LOGGING'] && ENV['VERBOSE_LOGGING'] == 'true'
    @logger.level = Logger::DEBUG
  end

  def self.logger
    @logger
  end

  def self.logger=(logger)
    @logger = logger
  end
end

require 'multi_json'
require 'ey-hmac'
require 'faraday'
require 'gzipped_tar'
require 'riddle'
require 'riddle/0.9.9'
require 'pusher-client'

PusherClient.logger = FlyingSphinx.logger

require 'flying_sphinx/version'
require 'flying_sphinx/action'
require 'flying_sphinx/api'
require 'flying_sphinx/cli'
require 'flying_sphinx/commands'
require 'flying_sphinx/configuration'
require 'flying_sphinx/configuration_options'
require 'flying_sphinx/configurer'
require 'flying_sphinx/controller'
require 'flying_sphinx/rake_interface'
require 'flying_sphinx/setting_files'

require 'flying_sphinx/request/hmac'
require 'flying_sphinx/response/invalid'
require 'flying_sphinx/response/json'
require 'flying_sphinx/response/logger'

if defined?(Rails) && defined?(Rails::Railtie)
  require 'flying_sphinx/railtie'
end

ThinkingSphinx.rake_interface = FlyingSphinx::RakeInterface
