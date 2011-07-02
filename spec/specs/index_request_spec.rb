require 'spec_helper'

describe FlyingSphinx::IndexRequest do
  let(:api)           { FlyingSphinx::API.new 'foo', 'bar' }
  let(:configuration) {
    stub(:configuration, :api => api, :sphinx_configuration => 'foo {}',
      :wordform_file_pairs => {})
  }
  
  let(:index_response)    {
    stub(:response, :body => stub(:body, :id => 42, :status => 'OK'))
  }
  let(:blocked_response)  {
    stub(:response, :body => stub(:body, :id => nil, :status => 'BLOCKED'))
  }
    
  before :each do
    ThinkingSphinx.database_adapter = FlyingSphinx::HerokuSharedAdapter
    
    FlyingSphinx::Configuration.stub!(:new => configuration)
    FlyingSphinx::Tunnel.stub(:connect) { |config, block| block.call }
  end
  
  describe '.cancel_jobs' do
    before :each do
      Delayed::Job.stub!(:delete_all => true)
    end
    
    it "should not delete any rows if the delayed_jobs table does not exist" do
      Delayed::Job.stub!(:table_exists? => false)
      Delayed::Job.should_not_receive(:delete_all)
      
      FlyingSphinx::IndexRequest.cancel_jobs
    end
    
    it "should delete rows if the delayed_jobs table does exist" do
      Delayed::Job.stub!(:table_exists? => true)
      Delayed::Job.should_receive(:delete_all)
      
      FlyingSphinx::IndexRequest.cancel_jobs
    end
    
    it "should delete only Thinking Sphinx jobs" do
      Delayed::Job.stub!(:table_exists? => true)
      Delayed::Job.should_receive(:delete_all) do |sql|
        sql.should match(/handler LIKE '--- !ruby\/object:FlyingSphinx::\%'/)
      end
      
      FlyingSphinx::IndexRequest.cancel_jobs
    end
  end
  
  describe '#update_and_index' do
    let(:index_request) { FlyingSphinx::IndexRequest.new }
    let(:conf_params)   { { :configuration => 'foo {}' } }
    let(:index_params)  { { :indices => '' } }
        
    it "makes a new request" do
      api.should_receive(:put).with('/', conf_params).and_return('ok')
      api.should_receive(:post).
        with('indices', index_params).and_return(index_response)
      
      begin
        Timeout::timeout(0.2) {
          index_request.update_and_index
        }
      rescue Timeout::Error
      end
    end
    
    context 'with wordforms' do
      let(:file_params) {
        {:setting => 'wordforms', :file_name => 'bar.txt', :content => 'baz'}
      }
      
      before :each do
        configuration.stub!(:wordform_file_pairs => {'foo.txt' => 'bar.txt'})
        index_request.stub!(:open => double('file', :read => 'baz'))
      end
      
      it "sends the wordform file" do
        api.should_receive(:put).with('/', conf_params).and_return('ok')
        api.should_receive(:post).with('/add_file', file_params).
          and_return('ok')
        api.should_receive(:post).
          with('indices', index_params).and_return(index_response)
        
        begin
          Timeout::timeout(0.2) {
            index_request.update_and_index
          }
        rescue Timeout::Error
        end
      end
    end
    
    context 'delta request without delta support' do
      it "should explain why the request failed" do
        api.should_receive(:put).
          with('/', conf_params).and_return('ok')
        api.should_receive(:post).
          with('indices', index_params).and_return(blocked_response)
        index_request.should_receive(:puts).
          with('Your account does not support delta indexing. Upgrading plans is probably the best way around this.')

        index_request.update_and_index
      end
    end
    
    context 'request for a MySQL database' do
      before :each do
        ThinkingSphinx.database_adapter = nil
      end
      
      after :each do
        ThinkingSphinx.database_adapter = FlyingSphinx::HerokuSharedAdapter
      end
      
      it "should not establish an SSH connection" do
        FlyingSphinx::Tunnel.should_not_receive(:connect)
        
        api.should_receive(:put).with('/', conf_params).and_return('ok')
        api.should_receive(:post).
          with('indices', index_params).and_return(index_response)
        api.should_receive(:get).with('indices/42').
          and_return(stub(:response, :body => stub(:body, :status => 'FINISHED')))
        
        index_request.update_and_index
      end
    end
  end
  
  describe '#perform' do
    let(:index_request) { FlyingSphinx::IndexRequest.new ['foo_delta'] }
    let(:index_params)  { { :indices => 'foo_delta' } }
    
    it "makes a new request" do
      api.should_receive(:post).
        with('indices', index_params).and_return(index_response)
      
      begin
        Timeout::timeout(0.2) {
          index_request.perform
        }
      rescue Timeout::Error
      end
    end
  end
  
  describe '#status_message' do
    let(:index_request)     { FlyingSphinx::IndexRequest.new }
    let(:finished_response) {
      stub(:response, :body => stub(:body, :status => 'FINISHED'))
    }
    let(:failure_response)  {
      stub(:response, :body => stub(:body, :status => 'FAILED'))
    }
    let(:pending_response)  {
      stub(:response, :body => stub(:body, :status => 'PENDING'))
    }
    let(:unknown_response)  {
      stub(:response, :body => stub(:body, :status => 'UNKNOWN'))
    }
    
    before :each do
      api.stub(:post => index_response)
      
      index_request.instance_variable_set :@index_id, 42
    end
    
    it "returns with a positive message on success" do
      api.stub(:get => finished_response)
      
      index_request.status_message.should == 'Index Request has completed.'
    end
    
    it "returns with a failure message on failure" do
      api.stub(:get => failure_response)
      
      index_request.status_message.should == 'Index Request failed.'
    end
    
    it "warns the user if the request is still pending" do
      api.stub(:get => pending_response)
      
      index_request.status_message.should == 'Index Request is still pending - something has gone wrong.'
    end
    
    it "treats all other statuses as unknown" do
      api.stub(:get => unknown_response)
      
      index_request.status_message.should == "Unknown index response: 'UNKNOWN'."
    end
    
    it "raises a warning if the index id isn't set" do
      index_request.instance_variable_set :@index_id, nil
      
      lambda {
        index_request.status_message
      }.should raise_error
    end
  end
  
  describe "#display_name" do
    let(:index_request) {
      FlyingSphinx::IndexRequest.new ['foo_core', 'bar_core']
    }
    
    it "should display class name with all indexes" do
      index_request.display_name.should == "FlyingSphinx::IndexRequest for foo_core, bar_core"
    end
  end
end
