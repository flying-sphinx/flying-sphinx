require 'logger'

module FlyingSphinx
  module Translators
    #
  end

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

  def self.translator
    @translator
  end

  def self.translator=(translator)
    @translator = translator
  end
end

require 'multi_json'
require 'faraday'
require 'riddle'
require 'riddle/0.9.9'
require 'pusher-client'

PusherClient.logger = FlyingSphinx.logger

require 'flying_sphinx/action'
require 'flying_sphinx/api'
require 'flying_sphinx/binary'
require 'flying_sphinx/cli'
require 'flying_sphinx/configuration'
require 'flying_sphinx/configuration_options'
require 'flying_sphinx/controller'
require 'flying_sphinx/gzipped_hash'
require 'flying_sphinx/setting_files'
require 'flying_sphinx/sphinxql'
require 'flying_sphinx/version'

if defined?(Rails) && defined?(Rails::Railtie)
  require 'flying_sphinx/railtie'
elsif defined?(Rails) && defined?(Rails::Plugin)
  require 'flying_sphinx/rails'
end
