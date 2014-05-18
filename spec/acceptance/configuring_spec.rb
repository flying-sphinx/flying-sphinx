require 'spec_helper'

describe 'Configuring Sphinx' do
  let(:cli)           { FlyingSphinx::CLI.new 'configure' }
  let(:translator)    { double 'Translator', :sphinx_indices => [index],
    :sphinx_configuration => 'searchd { }' }
  let(:index)         { double 'Index' }
  let(:configuration) { double 'Configuration', :version => nil}

  before :each do
    stub_const 'ThinkingSphinx::Configuration', double(:instance => configuration)
    allow(FlyingSphinx).to receive(:translator).and_return(translator)
    allow(Digest::MD5).to receive(:hexdigest).and_return('abc')

    stub_digest_request(:get, 'https://papyrus.flying-sphinx.com/').
      to_return(:status => 200, :body => '[]')
    stub_digest_request(:put, %r{https://papyrus\.flying-sphinx\.com/}).
      to_return(:status => 200, :body => '{}')

    stub_digest_request(:post, 'https://flying-sphinx.com/api/my/app/v5/perform').
      to_return(:status => 200, :body => '{"id":953, "status":"OK"}')
  end

  it 'sends the configuration to Papyrus' do
    SuccessfulAction.new(953).matches? lambda { cli.run }

    expect(
      a_digest_request(:put, 'https://papyrus.flying-sphinx.com/sphinx/config.conf').
      with { |request|
        request.headers['Content-Type'] == 'application/gzip' &&
        FlyingSphinx::GZipper.decode(request.body) == 'searchd { }'
      }
    ).to have_been_made
  end

  it 'sends the Sphinx version to Papyrus' do
    SuccessfulAction.new(953).matches? lambda { cli.run }

    expect(
      a_digest_request(:put, 'https://papyrus.flying-sphinx.com/sphinx/version.txt').
      with { |request|
        request.headers['Content-Type'] == 'application/gzip' &&
        FlyingSphinx::GZipper.decode(request.body) == '2.1.4'
      }
    ).to have_been_made
  end

  it 'informs Thebes that it should update the configuration' do
    SuccessfulAction.new(953).matches? lambda { cli.run }

    expect(
      a_digest_request(:post, 'https://flying-sphinx.com/api/my/app/v5/perform').
        with(:body => {:action => 'configure'})
    ).to have_been_made
  end

  it 'allows for custom sphinx configuration' do
    allow(File).to receive(:read).with('my/path.conf').and_return('indexer { }')

    cli = FlyingSphinx::CLI.new 'configure', ['my/path.conf']
    SuccessfulAction.new(953).matches? lambda { cli.run }

    expect(
      a_digest_request(:put, 'https://papyrus.flying-sphinx.com/sphinx/config.conf').
      with { |request|
        request.headers['Content-Type'] == 'application/gzip' &&
        FlyingSphinx::GZipper.decode(request.body) == 'indexer { }'
      }
    ).to have_been_made
  end

  it 'allows for custom Sphinx versions' do
    allow(configuration).to receive(:version).and_return('2.0.6')

    SuccessfulAction.new(953).matches? lambda { cli.run }

    expect(
      a_digest_request(:put, 'https://papyrus.flying-sphinx.com/sphinx/version.txt').
      with { |request|
        request.headers['Content-Type'] == 'application/gzip' &&
        FlyingSphinx::GZipper.decode(request.body) == '2.0.6'
      }
    ).to have_been_made
  end

  it 'uploads additional files' do
    allow(index).to receive(:stopwords).and_return('all/stop.txt')
    allow(File).to receive(:read).with('all/stop.txt').
      and_return('stopping all the words')
    allow(Digest::MD5).to receive(:file).with('all/stop.txt').
      and_return(double(:hexdigest => 'something'))

    SuccessfulAction.new(953).matches? lambda { cli.run }

    expect(
      a_digest_request(:put, 'https://papyrus.flying-sphinx.com/stopwords/stop.txt').
      with { |request|
        request.headers['Content-Type'] == 'application/gzip' &&
        FlyingSphinx::GZipper.decode(request.body) == 'stopping all the words'
      }
    ).to have_been_made
  end

  it 'does not upload configuration when the cached version matches' do
    stub_digest_request(:get, 'https://papyrus.flying-sphinx.com/').to_return(
      :status => 200,
      :body   => '[{"key":"sphinx/config.conf","md5":"foo"}]'
    )
    allow(Digest::MD5).to receive(:hexdigest).with('searchd { }').
      and_return('foo')

    SuccessfulAction.new(953).matches? lambda { cli.run }

    expect(
      a_request(:put, 'https://papyrus.flying-sphinx.com/sphinx/config.conf')
    ).to_not have_been_made
  end

  it 'does not upload additional files when cached version matches' do
    stub_digest_request(:get, 'https://papyrus.flying-sphinx.com/').to_return(
      :status => 200,
      :body   => '[{"key":"stopwords/stop.txt","md5":"foo"}]'
    )

    allow(index).to receive(:stopwords).and_return('all/stop.txt')
    allow(File).to receive(:read).with('all/stop.txt').
      and_return('stopping all the words')
    allow(Digest::MD5).to receive(:file).with('all/stop.txt').
      and_return(double(:hexdigest => 'foo'))

    SuccessfulAction.new(953).matches? lambda { cli.run }

    expect(
      a_request(:put, 'https://papyrus.flying-sphinx.com/stopwords/stop.txt')
    ).to_not have_been_made
  end

  it 'handles the full request successfully' do
    expect { cli.run }.to be_successful_with 953
  end
end
