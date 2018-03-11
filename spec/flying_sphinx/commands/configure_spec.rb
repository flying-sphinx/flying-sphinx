require "spec_helper"

RSpec.describe FlyingSphinx::Commands::Configure do
  let(:subject) do
    FlyingSphinx::Commands::Configure.new configuration_double, :api => api
  end
  let(:api) do
    double 'API', :identifier => 'foo', :post => {'status' => 'OK'}
  end
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

  it "raises an exception if an invalid path error is returned" do
    allow(api).to receive(:post).and_return('status' => 'INVALID PATH')

    expect { subject.call }.to raise_error(FlyingSphinx::Error)
  end

  it "raises an exception if an unknown error is returned" do
    allow(api).to receive(:post).and_return('status' => nil)

    expect { subject.call }.to raise_error(FlyingSphinx::Error)
  end
end
