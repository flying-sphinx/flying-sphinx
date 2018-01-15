require "spec_helper"

RSpec.describe FlyingSphinx::Commands::Stop do
  let(:subject) do
    FlyingSphinx::Commands::Stop.new configuration_double, :api => api
  end
  let(:api)          { double 'API', :identifier => 'foo', :post => true }
  let(:action_class) { double }

  before :each do
    stub_const 'FlyingSphinx::Action', action_class
    action_class.stub(:perform) { |identifier, &block| block.call }
  end

  it "sends through action" do
    expect(api).to receive(:post).with "/perform",
      :action => "stop"

    subject.call
  end
end
