module FlyingSphinx
  #
end

require 'faraday'
require 'faraday_middleware'
require 'riddle'
require 'riddle/0.9.9'

require 'flying_sphinx/api'
require 'flying_sphinx/cli'
require 'flying_sphinx/configuration'
require 'flying_sphinx/controller'
require 'flying_sphinx/flag_as_deleted_job'
require 'flying_sphinx/index_request'
require 'flying_sphinx/setting_files'
require 'flying_sphinx/sphinx_configuration'
require 'flying_sphinx/version'

require 'flying_sphinx/delayed_delta' if defined?(ThinkingSphinx)
require 'flying_sphinx/railtie'       if defined?(Rails)
