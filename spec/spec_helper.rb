$:.unshift File.dirname(__FILE__) + '/../lib'

require 'rubygems'
require 'bundler'
 
Bundler.require :default, :development

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

require 'flying_sphinx'
