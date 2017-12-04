require 'spec_helper'

describe FlyingSphinx::Controller do
  let(:controller)    { FlyingSphinx::Controller.new api }
  let(:api)           { double 'API', :identifier => 'foo', :put => true,
    :get => {"path" => "/foo", "url" => "https://confserver", "status" => "OK"} }
  let(:action_class)  { double }
  let(:configuration) { double 'TS Configuration' }
  let(:setting_files) { double :to_hash => {'extra' => 'wordforms/txt.txt',
    'wordforms/txt.txt' => 'something'} }
  let(:translator)    { double :sphinx_configuration => 'indexer ...' }

  before :each do
    stub_const 'FlyingSphinx::Action', action_class
    action_class.stub(:perform) do |identifier, &block|
      block.call
    end

    stub_const 'ThinkingSphinx::Configuration',
      double(:instance => configuration)

    stub_const 'FlyingSphinx::SettingFiles', double(:new => setting_files)
    FlyingSphinx.stub :translator => translator

    stub_request(:post, "https://confserver").to_return(:status => 200)
  end

  describe 'configure' do
    it 'sends data to the server' do
      api.should_receive(:post)

      controller.configure
    end

    it 'sends through gzipped configuration archive' do
      expect(api).to receive(:post).with '/perform',
        :action => 'configure',
        :path   => '/foo'

      controller.configure

      expect(
        a_multipart_request(:post, 'https://confserver').
        with_file { |contents|
          reader = GZippedTar::Reader.new contents

          reader.read("sphinx/raw.conf") == "indexer ..." &&
          reader.read("sphinx/version.txt") == "2.2.3" &&
          reader.read("wordforms/txt.txt") == "something"
        }
      ).to have_been_made
    end

    it 'sends through file if provided' do
      expect(api).to receive(:post).with '/perform',
        :action => 'configure',
        :path   => '/foo'

      controller.configure 'searchd ...'

      expect(
        a_multipart_request(:post, 'https://confserver').
        with_file { |contents|
          reader = GZippedTar::Reader.new contents

          reader.read("sphinx/raw.conf") == "searchd ..."
        }
      ).to have_been_made
    end
  end
end
