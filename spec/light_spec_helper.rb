require 'bundler/setup'
require 'rspec/fire'

module FlyingSphinx; end

RSpec.configure do |config|
  config.mock_with :rspec
  config.include(RSpec::Fire)
end
