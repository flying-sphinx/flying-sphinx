require "spec_helper"

RSpec.describe FlyingSphinx::Commands::IndexSQL do
  let(:subject) do
    FlyingSphinx::Commands::IndexSQL.new configuration_double, :api => api
  end
  let(:api) do
    double 'API', :identifier => 'foo', :post => {'status' => 'OK'}
  end
  let(:action_class) { double }

  before :each do
    stub_const 'FlyingSphinx::Action', action_class
    action_class.stub(:perform) { |identifier, &block| block.call }
  end

  context "synchronous" do
    it "sends the action" do
      expect(api).to receive(:post).with "/perform",
        :action  => "index",
        :indices => ""

      subject.call
    end

    it "waits for the action to finish" do
      expect(action_class).to receive(:perform) do |identifier, &block|
        block.call
      end

      subject.call
    end
  end

  context "asynchronous" do
    let(:subject) do
      FlyingSphinx::Commands::IndexSQL.new(
        double, :api => api, :indices => ["foo_delta"]
      )
    end

    it "sends the action" do
      expect(api).to receive(:post).with "/perform",
        :action  => "index",
        :indices => "foo_delta",
        :unique  => "true"

      subject.call
    end

    it "does not wait for the action to finish" do
      expect(action_class).not_to receive(:perform)

      subject.call
    end

    it "raises an exception if a blocked error is returned" do
      allow(api).to receive(:post).and_return('status' => 'BLOCKED')

      expect { subject.call }.to raise_error(FlyingSphinx::Error)
    end

    it "raises an exception if an unconfigured error is returned" do
      allow(api).to receive(:post).and_return('status' => 'UNCONFIGURED')

      expect { subject.call }.to raise_error(FlyingSphinx::Error)
    end
  end
end
