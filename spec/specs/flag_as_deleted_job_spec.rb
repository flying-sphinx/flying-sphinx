require 'spec_helper'
require 'mysql2/error'

describe FlyingSphinx::FlagAsDeletedJob do
  describe '#perform' do
    let(:job)        { FlyingSphinx::FlagAsDeletedJob.new('foo_core', 12) }
    let(:config)     { double('TS::Configuration', :connection => connection) }
    let(:connection) { stub('MySQL::Connection', :query => true) }

    before :each do
      stub_const 'ThinkingSphinx::Configuration', double(:instance => config)
      stub_const 'Riddle::Query', double(:update => 'UPDATE QUERY')
    end

    it "builds the update query" do
      Riddle::Query.should_receive(:update).
        with('foo_core', 12, :sphinx_deleted => true).
        and_return('UPDATE QUERY')

      job.perform
    end

    it "sends the query to the Sphinx connection" do
      connection.should_receive(:query).with('UPDATE QUERY')

      job.perform
    end

    it "does not care about MySQL errors" do
      connection.stub(:query).and_raise(Mysql2::Error.new(''))

      lambda { job.perform }.should_not raise_error
    end
  end
end
