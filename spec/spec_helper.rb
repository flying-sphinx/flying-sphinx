require 'rubygems'
require 'bundler'

require 'dotenv'
require 'webmock/rspec'
require 'em-websocket'

Dotenv.load '.env.test'
WebMock.disable_net_connect!

require 'active_support/core_ext/object/blank'
require 'thinking_sphinx'
require 'flying_sphinx'

unless FlyingSphinx.logger.level == Logger::DEBUG
  FlyingSphinx.logger.level = Logger::WARN
end

Dir["spec/support/**/*.rb"].each { |file| require File.expand_path(file) }
