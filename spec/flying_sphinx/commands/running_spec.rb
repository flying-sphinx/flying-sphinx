require "spec_helper"

RSpec.describe FlyingSphinx::Commands::Running do
  let(:subject) do
    FlyingSphinx::Commands::Running.new configuration_double, :api => api
  end
  let(:api) { double 'API', :identifier => 'foo', :get => {"running" => true} }

  it "sends through the API request" do
    expect(api).to receive(:get).with("/running").and_return("running" => true)

    subject.call
  end

  it "returns true when the API does" do
    expect(subject.call).to eq(true)
  end

  it "returns false when the API does" do
    allow(api).to receive(:get).with("/running").and_return("running" => false)

    expect(subject.call).to eq(false)
  end
end
