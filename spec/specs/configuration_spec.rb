require 'light_spec_helper'
require 'flying_sphinx/configuration'

describe FlyingSphinx::Configuration do
  let(:api)       { fire_double('FlyingSphinx::API',
    :get => double(:body => body, :status => 200)) }
  let(:body)      { double(:server => 'foo.bar.com', :port => 9319) }
  let(:ts_config) { fire_double('ThinkingSphinx::Configuration',
    :port= => 9319, :address= => 'foo.bar.com', :configuration => riddle) }
  let(:riddle)    { fire_double('Riddle::Configuration', :searchd => searchd) }
  let(:searchd)   { fire_double('Riddle::Configuration::Searchd') }

  before :each do
    fire_class_double('FlyingSphinx::API', :new => api).as_replaced_constant
    fire_class_double('ThinkingSphinx', :remote_sphinx= => true).
      as_replaced_constant
    fire_class_double('ThinkingSphinx::Configuration', :instance => ts_config).
      as_replaced_constant
  end

  describe '#initialize' do
    let(:api_key)    { 'foo-bar-baz' }
    let(:identifier) { 'my-identifier' }
    let(:config)     { FlyingSphinx::Configuration.new identifier, api_key }

    it "sets the host from the API information" do
      config.host.should == 'foo.bar.com'
    end

    it "sets the port from the API information" do
      config.port.should == 9319
    end

    it "sets the client key when possible" do
      searchd.stub :client_key => nil
      searchd.should_receive(:client_key=).with('my-identifier:foo-bar-baz')

      config
    end
  end
end
