require 'spec_helper'

describe FlyingSphinx::Configuration do
  describe '#initialize' do
    let(:api_server) { 'http://flying-sphinx.com/heroku' }
    let(:api_key)    { 'foo-bar-baz' }
    let(:heroku_id)  { 'app@heroku.com' }
    let(:encoded_heroku_id) {
      FakeWeb::Utility.encode_unsafe_chars_in_userinfo heroku_id
    }
    
    before :each do
      FakeWeb.register_uri(:get,
        "#{api_server}/app?api_key=#{api_key}&heroku_id=#{encoded_heroku_id}",
        :body => JSON.dump({:server => 'foo.bar.com', :port => 9319})
      )
    end
    
    it "requests details from the server with the given API key" do
      FlyingSphinx::Configuration.new heroku_id, api_key
      
      FakeWeb.should have_requested :get,
        "#{api_server}/app?api_key=#{api_key}&heroku_id=#{encoded_heroku_id}"
    end
    
    it "sets the host from the server information" do
      config = FlyingSphinx::Configuration.new heroku_id, api_key
      config.host.should == 'foo.bar.com'
    end
    
    it "sets the port from the server information" do
      config = FlyingSphinx::Configuration.new heroku_id, api_key
      config.port.should == 9319
    end
  end
end
