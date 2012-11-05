require 'light_spec_helper'
require 'flying_sphinx/sphinx_configuration'

describe FlyingSphinx::SphinxConfiguration do
  let(:configuration) { FlyingSphinx::SphinxConfiguration.new ts_config }
  let(:ts_config)     { fire_double('ThinkingSphinx::Configuration',
    :render => 'foo {}') }

  describe '#upload_to' do
    let(:api) { fire_double('FlyingSphinx::API', :put => true) }

    it "sends the configuration to the API" do
      api.should_receive(:put).with('/', :configuration => 'foo {}',
        :sphinx_version => '2.0.4')

      configuration.upload_to api
    end
  end
end
