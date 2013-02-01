require 'spec_helper'

describe FlyingSphinx::FlagAsDeletedJob do
  describe '#perform' do
    let(:client) { stub('client', :update => true) }
    let(:job)    { FlyingSphinx::FlagAsDeletedJob.new(['foo_core'], 12) }
    let(:connection) { double }

    before :each do
      stub_const 'ThinkingSphinx::Connection', connection
      connection.stub(:take).and_yield(client)
    end

    it "should update the specified index" do
      client.should_receive(:update) do |index, attributes, values|
        index.should == 'foo_core'
      end

      job.perform
    end

    it "should update all specified indexes" do
      job.indices = ['foo_core', 'bar_core']
      client.should_receive(:update).with('foo_core', anything, anything)
      client.should_receive(:update).with('bar_core', anything, anything)

      job.perform
    end

    it "should update the sphinx_deleted attribute" do
      client.should_receive(:update) do |index, attributes, values|
        attributes.should == ['sphinx_deleted']
      end

      job.perform
    end

    it "should set sphinx_deleted for the given document to true" do
      client.should_receive(:update) do |index, attributes, values|
        values[12].should == [1]
      end

      job.perform
    end
  end
end
