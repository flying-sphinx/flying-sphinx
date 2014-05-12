require 'spec_helper'

describe 'Configuring Sphinx' do
  let(:cli)        { FlyingSphinx::CLI.new 'configure' }
  let(:translator) { double 'Translator', :sphinx_indices => [index],
    :sphinx_configuration => 'searchd { }' }
  let(:index)      { double 'Index' }

  before :each do
    allow(FlyingSphinx).to receive(:translator).and_return(translator)

    stub_digest_request(:get, 'https://papyrus.flying-sphinx.com/').
      to_return(:status => 200, :body => '[]')
    stub_digest_request(:put, %r{https://papyrus\.flying-sphinx\.com/}).
      to_return(:status => 200, :body => '{}')

    stub_request(:put, 'https://flying-sphinx.com/api/my/app').
      to_return(:status => 200, :body => '{"id":953, "status":"OK"}')
  end

  it 'sends the configuration to Papyrus' do
    SuccessfulAction.new(953).matches? lambda { cli.run }

    expect(
      a_digest_request(:put, 'https://papyrus.flying-sphinx.com/sphinx/config.conf').
      with { |request|
        request.headers['Content-Type'] == 'application/gzip' &&
        ungzip(request.body) == 'searchd { }'
      }
    ).to have_been_made
  end

  it 'informs Thebes that it should update the configuration' do
    SuccessfulAction.new(953).matches? lambda { cli.run }

    expect(
      a_request(:put, 'https://flying-sphinx.com/api/my/app').
      with { |request| request.body.blank? }
    ).to have_been_made
  end

  it 'handles the full request successfully' do
    expect { cli.run }.to be_successful_with 953
  end
end
