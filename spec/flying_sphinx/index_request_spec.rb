require 'spec_helper'

describe FlyingSphinx::IndexRequest do
  let(:api)           { FlyingSphinx::API.new 'foo', 'bar' }
  let(:configuration) { stub(:configuration, :api => api) }
  
  before :each do
    FlyingSphinx::Tunnel.stub(:connect) { |config, block| block.call }
  end
  
  describe '#initialize' do
    it "makes a new request" do
      api.should_receive(:post).with('/app/indices').and_return(42)
      api.should_receive(:get).with('/app/indices/42').and_return('PENDING')
      
      begin
        Timeout::timeout(0.2) { FlyingSphinx::IndexRequest.new(configuration) }
      rescue Timeout::Error
      end
    end
    
    it "should finish when the index request has been completed" do
      api.should_receive(:post).with('/app/indices').and_return(42)
      api.should_receive(:get).with('/app/indices/42').and_return('FINISHED')
      
      FlyingSphinx::IndexRequest.new(configuration)
    end
  end
end
