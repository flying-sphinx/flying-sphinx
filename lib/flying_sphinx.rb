module FlyingSphinx
  #
end

require 'httparty'
require 'net/ssh'

require 'flying_sphinx/api'
require 'flying_sphinx/configuration'
require 'flying_sphinx/index_request'
require 'flying_sphinx/tunnel'

require 'flying_sphinx/railtie' if defined?(Rails)
