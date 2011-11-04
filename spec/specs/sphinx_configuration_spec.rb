require 'light_spec_helper'
require 'flying_sphinx/sphinx_configuration'

describe FlyingSphinx::SphinxConfiguration do
  let(:configuration) { FlyingSphinx::SphinxConfiguration.new ts_config }
  let(:ts_config)     { fire_double('ThinkingSphinx::Configuration',
    :render => 'foo {}', :searchd => searchd) }
  let(:searchd)       { fire_double('Riddle::Configuration::Searchd',
    :client_key= => true) }
  let(:fs_config)     { fire_double('FlyingSphinx::Configuration',
    :client_key => 'foo:bar') }

  describe '#upload_to' do
    before :each do
      stub_const 'FlyingSphinx::Configuration', double(:new => fs_config)
    end

    let(:api) { fire_double('FlyingSphinx::API', :put => true) }

    it "sets the client key" do
      searchd.should_receive(:client_key=).with('foo:bar')

      configuration.upload_to api
    end

    it "sends the configuration to the API" do
      api.should_receive(:put).with('/', :configuration => 'foo {}',
        :sphinx_version => '2.0.4')

      configuration.upload_to api
    end
  end
end
