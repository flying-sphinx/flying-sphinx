require 'bundler/setup'
require 'rspec/fire'

RSpec.configure do |config|
  config.mock_with :rspec
  config.include(RSpec::Fire)
end
