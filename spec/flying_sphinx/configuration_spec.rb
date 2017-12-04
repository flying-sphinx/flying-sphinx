require 'spec_helper'

describe FlyingSphinx::Configuration do
  let(:api)        { double 'FlyingSphinx::API', :get => body }
  let(:body)       { {'server' => 'foo.bar.com', 'port' => 9319} }
  let(:api_key)    { 'foo-bar-baz' }
  let(:identifier) { 'my-identifier' }
  let(:config)     { FlyingSphinx::Configuration.new identifier, api_key }

  before :each do
    stub_const 'FlyingSphinx::API', double(:new => api)
  end

  describe '#host' do
    it "reads the server from the API" do
      config.host.should == 'foo.bar.com'
    end
  end

  describe '#port' do
    it "reads the port from the API" do
      config.port.should == 9319
    end
  end
end
