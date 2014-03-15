require 'light_spec_helper'
require 'flying_sphinx/api'
require 'flying_sphinx/version'

describe FlyingSphinx::API do
  let(:api)        { FlyingSphinx::API.new 'foo', 'bar', adapter }
  let(:faraday)    { fire_class_double('Faraday', :new => connection) }
  let(:adapter)    { double('adapter') }
  let(:connection) { double('connection') }
  let(:logger)     { double :debug => true }
  let(:response)   { double :body => '', :status => 200 }

  before :each do
    faraday.as_replaced_constant

    stub_const 'MultiJson', double(:load => {})
    FlyingSphinx.stub :logger => logger
  end

  shared_examples_for 'an API call' do
    it "sets up a connection with the appropriate headers" do
      faraday.should_receive(:new) do |options|
        options[:headers].should == {
          'Accept'                  => 'application/vnd.flying-sphinx-v4+json',
          'X-Flying-Sphinx-Token'   => 'foo:bar',
          'X-Flying-Sphinx-Version' => FlyingSphinx::Version
        }

        connection
      end

      send_request
    end

    it "connects to flying-sphinx.com with SSL" do
      faraday.should_receive(:new) do |options|
        options[:url].should == 'https://flying-sphinx.com'

        connection
      end

      send_request
    end
  end

  describe '#get' do
    let(:request)      { double('request', :url => true) }
    let(:send_request) { api.get '/resource', 'param' => 'value' }

    before :each do
      connection.stub(:get).and_yield(request).and_return(response)
    end

    it_should_behave_like 'an API call'

    it "sends the GET request with the given path and data" do
      request.should_receive(:url).
        with('/api/my/app/resource', 'param' => 'value')

      send_request
    end
  end

  describe '#post' do
    let(:send_request) { api.post '/resource', 'param' => 'value' }

    before :each do
      connection.stub(:post => response)
    end

    it_should_behave_like 'an API call'

    it "sends the POST request with the given path and data" do
      connection.should_receive(:post).
        with('/api/my/app/resource', 'param' => 'value').
        and_return(response)

      send_request
    end
  end

  describe '#put' do
    let(:send_request) { api.put '/resource', 'param' => 'value' }

    before :each do
      connection.stub(:put => response)
    end

    it_should_behave_like 'an API call'

    it "sends the PUT request with the given path and data" do
      connection.should_receive(:put).
        with('/api/my/app/resource', 'param' => 'value').
        and_return(response)

      send_request
    end
  end
end
