require "spec_helper"

RSpec.describe FlyingSphinx::Commands::Merge do
  let(:subject) do
    FlyingSphinx::Commands::Merge.new configuration_double, :api => api,
      :core_index => core_index, :delta_index => delta_index,
      :filters => {:deleted => 0}
  end
  let(:api) do
    double 'API', :identifier => 'foo', :post => {'status' => 'OK'}
  end
  let(:core_index)   { double "index", :name => "core" }
  let(:delta_index)  { double "index", :name => "delta" }
  let(:action_class) { double }

  before :each do
    stub_const 'FlyingSphinx::Action', action_class
    action_class.stub(:perform) { |identifier, &block| block.call }
  end

  it "sends through action" do
    expect(api).to receive(:post).with "/perform",
      :action      => "merge",
      :core_index  => "core",
      :delta_index => "delta",
      :filters     => '{"deleted":0}'

    subject.call
  end
end
