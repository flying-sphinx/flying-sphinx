# frozen_string_literal: true

module CommandHelpers
  def configuration_double(stubs = {})
    double("ThinkingSphinx::Configuration", {:settings => {}}.merge(stubs))
  end
end

RSpec.configure do |config|
  config.include CommandHelpers
end
