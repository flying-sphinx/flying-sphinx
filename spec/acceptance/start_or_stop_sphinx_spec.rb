require 'spec_helper'

describe 'Starting Sphinx' do
  let(:cli) { FlyingSphinx::CLI.new 'start' }

  before :each do
    stub_digest_request(:post, 'https://flying-sphinx.com/api/my/app/v5/perform').
      to_return(:status => 200, :body => '{"id":429, "status":"OK"}')
  end

  it 'makes the request to the server' do
    SuccessfulAction.new(429).matches? lambda { cli.run }

    expect(
      a_digest_request(:post, 'https://flying-sphinx.com/api/my/app/v5/perform').
        with(:body => {:action => 'start'})
    ).to have_been_made
  end

  it 'completes the action successfully' do
    expect { cli.run }.to be_successful_with 429
  end
end

describe 'Stopping Sphinx' do
  let(:cli) { FlyingSphinx::CLI.new 'stop' }

  before :each do
    stub_digest_request(:post, 'https://flying-sphinx.com/api/my/app/v5/perform').
      to_return(:status => 200, :body => '{"id":537, "status":"OK"}')
  end

  it 'makes the request to the server' do
    SuccessfulAction.new(537).matches? lambda { cli.run }

    expect(
      a_digest_request(:post, 'https://flying-sphinx.com/api/my/app/v5/perform').
        with(:body => {:action => 'stop'})
    ).to have_been_made
  end

  it 'completes the action successfully' do
    expect { cli.run }.to be_successful_with 537
  end
end
