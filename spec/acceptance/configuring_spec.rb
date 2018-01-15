require 'spec_helper'
require 'cgi'

describe 'Configuring Sphinx' do
  let(:interface)     { ThinkingSphinx.rake_interface.new }
  let(:configuration) { double 'ThinkingSphinx::Configuration',
    :indices => [double('Index')], :render => 'searchd { }',
    :version => '2.2.11' }

  before :each do
    allow(ThinkingSphinx::Configuration).to receive(:instance).
      and_return(configuration)

    stub_hmac_request(:post, 'https://flying-sphinx.com/api/my/v5/perform').
      to_return(:body => '{"id":953, "status":"OK"}')
    stub_hmac_request(:get, "https://flying-sphinx.com/api/my/v5/presignature").
      to_return(
        :body => '{"url":"https://foo","path":"bar","fields":{},"status":"OK"}'
      )
    stub_request(:post, "https://foo/").to_return(:status => 200)
  end

  it 'sends the configuration to the server' do
    SuccessfulAction.new(953).matches? lambda { interface.configure }

    expect(
      a_hmac_request(:post, 'https://flying-sphinx.com/api/my/v5/perform').
      with { |request| CGI::parse(request.body)["action"] == ["configure"] }
    ).to have_been_made
  end

  it 'handles the full request successfully' do
    expect { interface.configure }.to be_successful_with 953
  end
end
