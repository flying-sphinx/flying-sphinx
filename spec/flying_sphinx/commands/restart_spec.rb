require "spec_helper"

RSpec.describe FlyingSphinx::Commands::Restart do
  let(:subject) do
    FlyingSphinx::Commands::Restart.new configuration_double, :api => api
  end
  let(:api) do
    double 'API', :identifier => 'foo', :post => {'status' => 'OK'}
  end
  let(:action_class) { double }

  before :each do
    stub_const 'FlyingSphinx::Action', action_class
    action_class.stub(:perform) { |identifier, &block| block.call }
  end

  it "sends through action" do
    expect(api).to receive(:post).with "/perform",
      :action => "restart"

    subject.call
  end
end
