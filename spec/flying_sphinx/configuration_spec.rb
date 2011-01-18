require 'spec_helper'

describe FlyingSphinx::Configuration do
  describe '#initialize' do
    let(:api_server) { 'https://flying-sphinx.com/heroku' }
    let(:api_key)    { 'foo-bar-baz' }
    let(:identifier)  { 'app@heroku.com' }
    let(:encoded_identifier) {
      FakeWeb::Utility.encode_unsafe_chars_in_userinfo identifier
    }
    
    before :each do
      FakeWeb.register_uri(:get,
        "#{api_server}/app?api_key=#{api_key}&identifier=#{encoded_identifier}",
        :body => JSON.dump(
          :server        => 'foo.bar.com',
          :port          => 9319,
          :database_port => 10001
        )
      )
    end
    
    it "requests details from the server with the given API key" do
      FlyingSphinx::Configuration.new identifier, api_key
      
      FakeWeb.should have_requested :get,
        "#{api_server}/app?api_key=#{api_key}&identifier=#{encoded_identifier}"
    end
    
    it "sets the host from the server information" do
      config = FlyingSphinx::Configuration.new identifier, api_key
      config.host.should == 'foo.bar.com'
    end
    
    it "sets the port from the server information" do
      config = FlyingSphinx::Configuration.new identifier, api_key
      config.port.should == 9319
    end
    
    it "sets the port from the server information" do
      config = FlyingSphinx::Configuration.new identifier, api_key
      config.database_port.should == 10001
    end
  end
end
