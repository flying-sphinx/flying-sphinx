module FlyingSphinx
  #
end

require 'faraday'
require 'faraday_middleware'
require 'riddle/0.9.9'

require 'flying_sphinx/api'
require 'flying_sphinx/configuration'
require 'flying_sphinx/delayed_delta'
require 'flying_sphinx/flag_as_deleted_job'
require 'flying_sphinx/heroku_shared_adapter'
require 'flying_sphinx/index_request'
require 'flying_sphinx/setting_files'
require 'flying_sphinx/sphinx_configuration'
require 'flying_sphinx/version'

if defined?(Rails) && defined?(Rails::Railtie)
  require 'flying_sphinx/railtie'
elsif defined?(Rails)
  require 'flying_sphinx/rails'
end
