require 'spec_helper'

describe FlyingSphinx::API do
  let(:api)        { FlyingSphinx::API.new 'foo', 'bar' }
  let(:faraday)    { double('Faraday', :new => connection) }
  let(:connection) { double('connection') }
  let(:logger)     { double :debug => true }
  let(:response)   { double :body => '', :status => 200 }

  before :each do
    stub_const 'MultiJson', double(:load => {})
    stub_const 'Faraday',   faraday
    allow(FlyingSphinx).to receive(:logger).and_return(logger)
  end

  shared_examples_for 'an API call' do
    it "sets up a connection with the appropriate headers" do
      expect(faraday).to receive(:new).with(hash_including(:headers => {
        'X-Flying-Sphinx-Version' => FlyingSphinx::Version
      })).and_return(connection)

      send_request
    end

    it "connects to flying-sphinx.com with SSL" do
      expect(faraday).to receive(:new).with(hash_including(
        :url => 'https://flying-sphinx.com'
      ))

      send_request
    end
  end

  describe '#get' do
    let(:request)      { double('request', :url => true) }
    let(:send_request) { api.get '/resource', 'param' => 'value' }

    before :each do
      allow(connection).to receive(:get).and_return(response)
    end

    it_should_behave_like 'an API call'

    it "sends the GET request with the given path and data" do
      expect(connection).to receive(:get).
        with('/api/my/app/v5/resource', 'param' => 'value').
        and_return(response)

      send_request
    end
  end

  describe '#post' do
    let(:send_request) { api.post '/resource', 'param' => 'value' }

    before :each do
      allow(connection).to receive(:post).and_return(response)
    end

    it_should_behave_like 'an API call'

    it "sends the POST request with the given path and data" do
      expect(connection).to receive(:post).
        with('/api/my/app/v5/resource', 'param' => 'value').
        and_return(response)

      send_request
    end
  end
end
