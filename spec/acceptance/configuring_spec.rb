require 'spec_helper'
require 'cgi'

describe 'Configuring Sphinx' do
  let(:cli)        { FlyingSphinx::CLI.new 'configure' }
  let(:translator) { double 'Translator', :sphinx_indices => [index],
    :sphinx_configuration => 'searchd { }' }
  let(:index)      { double 'Index' }

  before :each do
    allow(FlyingSphinx).to receive(:translator).and_return(translator)

    stub_hmac_request(:post, 'https://flying-sphinx.com/api/my/v5/perform').
      to_return(:body => '{"id":953, "status":"OK"}')
    stub_hmac_request(:get, "https://flying-sphinx.com/api/my/v5/presignature").
      to_return(
        :body => '{"url":"https://foo","path":"bar","fields":{},"status":"OK"}'
      )
    stub_request(:post, "https://foo/").to_return(:status => 200)
  end

  it 'sends the configuration to the server' do
    SuccessfulAction.new(953).matches? lambda { cli.run }

    expect(
      a_hmac_request(:post, 'https://flying-sphinx.com/api/my/v5/perform').
      with { |request| CGI::parse(request.body)["action"] == ["configure"] }
    ).to have_been_made
  end

  it 'handles the full request successfully' do
    expect { cli.run }.to be_successful_with 953
  end
end
