require 'spec_helper'

describe FlyingSphinx::DelayedDelta do
  describe '.enqueue_unless_duplicates' do
    let(:config) { double('TS Configuration', :settings => {}) }
    let(:job)    { double }

    before :each do
      stub_const 'ThinkingSphinx::Configuration', double(:instance => config)
      stub_const 'Delayed::Job',                  double(:count => 0)

      Delayed::Job.stub :where => Delayed::Job

      config.settings['delayed_job_priority'] = 2
    end

    it "should enqueue if there's no existing jobs for the same index" do
      Delayed::Job.should_receive(:enqueue).with(job, :priority => 2)

      FlyingSphinx::DelayedDelta.enqueue_unless_duplicates job
    end

    it "should not enqueue the job if there's an existing job already" do
      Delayed::Job.stub :count => 1

      Delayed::Job.should_not_receive(:enqueue)

      FlyingSphinx::DelayedDelta.enqueue_unless_duplicates job
    end
  end

  describe '#delete' do
    let(:delayed_delta) { FlyingSphinx::DelayedDelta.new double }
    let(:config)        { double('TS::Configuration', :settings => {}) }
    let(:index)         { double('Index', :name => 'foo_core',
      :document_id_for_key => 54) }
    let(:instance)      { double('AR::Base', :id => 15) }
    let(:job)           { double('FADJ Job') }

    before :each do
      stub_const 'FlyingSphinx::FlagAsDeletedJob', double(:new => job)
      stub_const 'Delayed::Job', double(:enqueue => true)
      stub_const 'ThinkingSphinx::Configuration', double(:instance => config)

      config.settings['delayed_job_priority'] = 4
    end

    it "converts the instance id to a document id" do
      index.should_receive(:document_id_for_key).with(15).and_return(54)

      delayed_delta.delete index, instance
    end

    it "creates a flag-as-deleted job" do
      FlyingSphinx::FlagAsDeletedJob.should_receive(:new).with('foo_core', 54).
        and_return(job)

      delayed_delta.delete index, instance
    end

    it "queues up the job" do
      Delayed::Job.should_receive(:enqueue).with(job, :priority => 4)

      delayed_delta.delete index, instance
    end
  end

  describe '#index' do
    let(:delayed_delta) { FlyingSphinx::DelayedDelta.new double }
    let(:index)         { double('Index', :name => 'foo_delta') }
    let(:job)           { double('Index Job') }

    before :each do
      stub_const 'FlyingSphinx::IndexRequest', double(:new => job)

      FlyingSphinx::DelayedDelta.stub :enqueue_unless_duplicates => true
    end

    it "creates a new index request" do
      FlyingSphinx::IndexRequest.should_receive(:new).with('foo_delta', true).
        and_return(job)

      delayed_delta.index index
    end

    it "should enqueue a delta job for the appropriate indexes" do
      FlyingSphinx::DelayedDelta.should_receive(:enqueue_unless_duplicates).
        with(job)

      delayed_delta.index index
    end
  end
end
