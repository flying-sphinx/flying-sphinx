require 'spec_helper'

describe FlyingSphinx::DelayedDelta do
  describe '.enqueue' do
    before :each do
      Delayed::Job.stub!(:count => 0)
    end
    
    it "should enqueue if there's no existing jobs for the same index" do
      Delayed::Job.should_receive(:enqueue)
      
      FlyingSphinx::DelayedDelta.enqueue(stub('object'))
    end
    
    it "should not enqueue the job if there's an existing job already" do
      Delayed::Job.stub!(:count => 1)
      Delayed::Job.should_not_receive(:enqueue)
      
      FlyingSphinx::DelayedDelta.enqueue(stub('object'))
    end
  end
  
  describe '#index' do
    let(:config)        { ThinkingSphinx::Configuration.instance }
    let(:delayed_delta) { FlyingSphinx::DelayedDelta.new stub('instance'), {} }
    let(:model)         {
      stub 'foo',
        :name              => 'foo',
        :core_index_names  => ['foo_core'],
        :delta_index_names => ['foo_delta']
    }
    let(:instance) { stub('instance', :sphinx_document_id => 42) }
    
    before :each do
      ThinkingSphinx.updates_enabled = true
      ThinkingSphinx.deltas_enabled  = true
      
      config.delayed_job_priority = 2
      
      FlyingSphinx::DelayedDelta.stub!(:enqueue => true)
      Delayed::Job.stub!(:enqueue => true, :inspect => 'Delayed::Job')
      
      delayed_delta.stub!(:toggled => true)
    end
    
    context 'updates disabled' do
      before :each do
        ThinkingSphinx.updates_enabled = false
      end
      
      it "should not enqueue a delta job" do
        FlyingSphinx::DelayedDelta.should_not_receive(:enqueue)
        
        delayed_delta.index model
      end
      
      it "should not enqueue a flag as deleted job" do
        Delayed::Job.should_not_receive(:enqueue)
        
        delayed_delta.index model
      end
    end
    
    context 'deltas disabled' do
      before :each do
        ThinkingSphinx.deltas_enabled = false
      end
      
      it "should not enqueue a delta job" do
        FlyingSphinx::DelayedDelta.should_not_receive(:enqueue)
        
        delayed_delta.index model
      end
      
      it "should not enqueue a flag as deleted job" do
        Delayed::Job.should_not_receive(:enqueue)
        
        delayed_delta.index model
      end
    end
    
    context "instance isn't toggled" do
      before :each do
        delayed_delta.stub!(:toggled => false)
      end
      
      it "should not enqueue a delta job" do
        FlyingSphinx::DelayedDelta.should_not_receive(:enqueue)
        
        delayed_delta.index model, instance
      end
      
      it "should not enqueue a flag as deleted job" do
        Delayed::Job.should_not_receive(:enqueue)
        
        delayed_delta.index model, instance
      end
    end
    
    it "should enqueue a delta job for the appropriate indexes" do
      FlyingSphinx::DelayedDelta.should_receive(:enqueue) do |job, priority|
        job.indices.should == ['foo_delta']
      end
      
      delayed_delta.index model
    end
    
    it "should use the defined priority for the delta job" do
      FlyingSphinx::DelayedDelta.should_receive(:enqueue) do |job, priority|
        priority.should == 2
      end
      
      delayed_delta.index model
    end
    
    it "should enqueue a flag-as-deleted job for the appropriate indexes" do
      Delayed::Job.should_receive(:enqueue) do |job, options|
        job.indices.should == ['foo_core']
      end
      
      delayed_delta.index model, instance
    end
    
    it "should enqueue a flag-as-deleted job for the appropriate id" do
      Delayed::Job.should_receive(:enqueue) do |job, options|
        job.document_id.should == 42
      end
      
      delayed_delta.index model, instance
    end
    
    it "should use the defined priority for the flag-as-deleted job" do
      Delayed::Job.should_receive(:enqueue) do |job, options|
        options[:priority].should == 2
      end
      
      delayed_delta.index model, instance
    end
    
    it "should not enqueue a flag-as-deleted job if no instance is provided" do
      Delayed::Job.should_not_receive(:enqueue)
      
      delayed_delta.index model
    end
  end
end
