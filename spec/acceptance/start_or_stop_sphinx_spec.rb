require 'spec_helper'

describe 'Starting Sphinx' do
  let(:cli) { FlyingSphinx::CLI.new 'start' }

  before :each do
    stub_hmac_request(:post, 'https://flying-sphinx.com/api/my/v5/perform').
      to_return(:status => 200, :body => '{"id":429, "status":"OK"}')
  end

  it 'makes the request to the server', :retry => 3 do
    expect { cli.run }.to be_successful_with 429

    expect(
      a_hmac_request(:post, 'https://flying-sphinx.com/api/my/v5/perform').
        with(:body => {:action => 'start'})
    ).to have_been_made
  end
end

describe 'Stopping Sphinx', :retry => 3 do
  let(:cli) { FlyingSphinx::CLI.new 'stop' }

  before :each do
    stub_request(:post, 'https://flying-sphinx.com/api/my/v5/perform').
      to_return(:status => 200, :body => '{"id":537, "status":"OK"}')
  end

  it 'makes the request to the server', :retry => 3 do
    expect { cli.run }.to be_successful_with 537

    expect(
      a_hmac_request(:post, 'https://flying-sphinx.com/api/my/v5/perform').
        with(:body => {:action => 'stop'})
    ).to have_been_made
  end
end
