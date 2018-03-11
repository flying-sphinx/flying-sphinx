require "spec_helper"

RSpec.describe FlyingSphinx::Commands::StartAttached do
  let(:subject) do
    FlyingSphinx::Commands::StartAttached.new(configuration_double, {}, stream)
  end
  let(:stream) { double 'Stream', :puts => nil }

  it "prints a warning" do
    expect(stream).to receive(:puts)

    subject.call
  end
end
