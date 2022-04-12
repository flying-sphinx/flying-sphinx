require 'rubygems'
require 'bundler'

require 'dotenv'
require 'webmock/rspec'
require 'rack'

Dotenv.load '.env.test'
WebMock.disable_net_connect!

require 'thinking_sphinx'
require 'flying_sphinx'

require 'flying_sphinx/commands'
ThinkingSphinx.rake_interface = FlyingSphinx::RakeInterface

unless FlyingSphinx.logger.level == Logger::DEBUG
  FlyingSphinx.logger.level = Logger::WARN
end

Dir["spec/support/**/*.rb"].each { |file| require File.expand_path(file) }
