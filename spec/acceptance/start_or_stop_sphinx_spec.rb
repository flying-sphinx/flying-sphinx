require 'spec_helper'

describe 'Starting Sphinx' do
  let(:cli) { FlyingSphinx::CLI.new 'start' }

  before :each do
    stub_request(:post, 'https://flying-sphinx.com/api/my/app/perform').
      with(:body => {:action => 'start'}).
      to_return(:status => 200, :body => '{"id":429, "status":"OK"}')
  end

  it 'makes the request to the server' do
    expect { cli.run }.to be_successful_with 429
  end
end

describe 'Stopping Sphinx' do
  let(:cli) { FlyingSphinx::CLI.new 'stop' }

  before :each do
    stub_request(:post, 'https://flying-sphinx.com/api/my/app/perform').
      with(:body => {:action => 'stop'}).
      to_return(:status => 200, :body => '{"id":537, "status":"OK"}')
  end

  it 'makes the request to the server' do
    expect { cli.run }.to be_successful_with 537
  end
end
