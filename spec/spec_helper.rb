require 'rubygems'
begin
  require 'bundler'
rescue LoadError
  puts "although not required, it's recommended you use bundler during development"
end

require 'thinking-sphinx'
require 'flying_sphinx'
require 'delayed_job'

require 'fakeweb'
require 'fakeweb_matcher'

Delayed::Worker.backend = :active_record

require 'support/fakeweb'
require 'support/timeout'