require 'light_spec_helper'
require 'multi_json'
require 'flying_sphinx/action'

describe FlyingSphinx::Action do
  let(:action)   { FlyingSphinx::Action.new 'abc123', 1, &block }
  let(:block)    { Proc.new { response } }
  let(:socket)   { double 'socket', :connect => true, :disconnect => true,
    :subscribe => true, :[] => channel, :connected => true }
  let(:channel)  { double 'channel', :bind => true }
  let(:response) { {'status' => 'OK', 'id' => 748} }
  let(:logger)   { double 'logger', :debug => true }

  before :each do
    stub_const 'PusherClient::Socket', double(:new => socket)
    stub_const 'FlyingSphinx::API::PUSHER_KEY', 'secret'

    FlyingSphinx.stub :logger => logger
  end

  def perform_and_complete(action)
    thread = Thread.new { action.perform }
    sleep 0.01
    action.send :completion, '{"id":748}'
    thread.join
  end

  describe '#perform' do
    it "sets up a connection to Pusher" do
      socket.should_receive(:connect)

      perform_and_complete action
    end

    it "subscribes to the identifier channel" do
      socket.should_receive(:subscribe).with('abc123')

      perform_and_complete action
    end

    it "subscribes to debug, completion and failure events" do
      channel.should_receive(:bind).with('debug').once
      channel.should_receive(:bind).with('completion').once
      channel.should_receive(:bind).with('failure').once

      perform_and_complete action
    end

    it "calls the provided block" do
      block.should_receive(:call).and_return(response)

      perform_and_complete action
    end

    it "raises an error if the response's status is BLOCKED" do
      response.stub :status => 'BLOCKED'

      lambda { action.perform }.should raise_error
    end

    it "retries the block if it raises an error" do
      calls = 0
      action = FlyingSphinx::Action.new 'abc123', 1 do
        calls += 1
        raise "Exception" if calls <= 1

        response
      end

      lambda { perform_and_complete action }.should_not raise_error
    end

    it "only retries four times" do
      calls = 0
      action = FlyingSphinx::Action.new 'abc123', 1 do
        calls += 1
        raise "Exception" if calls <= 5

        response
      end

      lambda { perform_and_complete action }.should raise_error
    end

    it "logs a warning when the action fails" do
      logger.should_receive(:warn).with("Action failed.")

      thread = Thread.new { action.perform }
      sleep 0.01
      action.send :failure, '{"id":748}'
      thread.join
    end

    it "disconnects the socket" do
      socket.should_receive(:disconnect)

      perform_and_complete action
    end
  end
end
