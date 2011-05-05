require 'rubygems'
begin
  require 'bundler'
rescue LoadError
  puts "although not required, it's recommended you use bundler during development"
end

require 'timeout'

require 'thinking-sphinx'
require 'flying_sphinx'
require 'delayed_job'

require 'fakeweb'
require 'fakeweb_matcher'

FakeWeb.allow_net_connect = false

Delayed::Worker.backend = :active_record

# we don't want a checking of interval in testing
FlyingSphinx::IndexRequest.send(:remove_const, :INDEX_COMPLETE_CHECKING_INTERVAL)
FlyingSphinx::IndexRequest::INDEX_COMPLETE_CHECKING_INTERVAL = 0