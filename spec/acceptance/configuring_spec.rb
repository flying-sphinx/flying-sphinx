require 'spec_helper'

describe 'Configuring Sphinx' do
  let(:cli)        { FlyingSphinx::CLI.new 'configure' }
  let(:translator) { double 'Translator', :sphinx_indices => [index],
    :sphinx_configuration => 'searchd { }' }
  let(:index)      { double 'Index' }

  before :each do
    allow(FlyingSphinx).to receive(:translator).and_return(translator)

    stub_request(:put, 'https://flying-sphinx.com/api/my/app/configure').
      to_return(:status => 200, :body => '{"id":953, "status":"OK"}')
  end

  it 'sends the configuration to the server' do
    SuccessfulAction.new(953).matches? lambda { cli.run }

    expect(
      a_request(:put, 'https://flying-sphinx.com/api/my/app/configure').
      with { |request| request.body.present? }
    ).to have_been_made
  end

  it 'handles the full request successfully' do
    expect { cli.run }.to be_successful_with 953
  end
end
