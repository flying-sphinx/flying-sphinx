require 'rubygems'
require 'bundler'

require 'timeout'
require 'thinking-sphinx'
require 'flying_sphinx'
require 'delayed_job'

require 'fakeweb'
require 'fakeweb_matcher'

FakeWeb.allow_net_connect = false
Delayed::Worker.backend   = :active_record
