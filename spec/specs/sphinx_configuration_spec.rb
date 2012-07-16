require 'light_spec_helper'
require 'flying_sphinx/sphinx_configuration'

describe FlyingSphinx::SphinxConfiguration do
  let(:configuration) { FlyingSphinx::SphinxConfiguration.new ts_config }
  let(:ts_config)     { fire_double('ThinkingSphinx::Configuration',
    :configuration => riddle_config, :version => '2.1.0-dev',
    :generate => true) }
  let(:riddle_config) { fire_double('Riddle::Configuration',
    :render => 'foo {}') }

  describe '#upload_to' do
    let(:api) { fire_double('FlyingSphinx::API', :put => true) }

    it "generates the Sphinx configuration" do
      ts_config.should_receive(:generate)

      configuration.upload_to api
    end

    it "sends the configuration to the API" do
      api.should_receive(:put).with('/', :configuration => 'foo {}',
        :sphinx_version => '2.1.0-dev', :tunnel => 'false')

      configuration.upload_to api
    end

    it "informs the API when tunnelling will be required" do
      api.should_receive(:put).with('/', :configuration => 'foo {}',
        :sphinx_version => '2.1.0-dev', :tunnel => 'true')

      configuration.upload_to api, true
    end
  end
end
