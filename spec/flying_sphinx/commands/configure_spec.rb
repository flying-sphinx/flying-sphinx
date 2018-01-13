require "spec_helper"

RSpec.describe FlyingSphinx::Commands::Configure do
  let(:subject) do
    FlyingSphinx::Commands::Configure.new double, :api => api
  end
  let(:api)          { double 'API', :identifier => 'foo', :post => true }
  let(:action_class) { double }

  before :each do
    stub_const 'FlyingSphinx::Action', action_class
    action_class.stub(:perform) { |identifier, &block| block.call }

    stub_const 'FlyingSphinx::Configurer', double(:call => "/foo")
  end

  it "sends through gzipped configuration archive" do
    expect(api).to receive(:post).with "/perform",
      :action => "configure",
      :path   => "/foo"

    subject.call
  end
end
