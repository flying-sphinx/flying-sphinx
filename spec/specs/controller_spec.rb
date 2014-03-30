require 'light_spec_helper'
require 'faraday'
require 'flying_sphinx/controller'
require 'flying_sphinx/configuration_options'
require 'flying_sphinx/gzipped_hash'

describe FlyingSphinx::Controller do
  let(:controller)    { FlyingSphinx::Controller.new api }
  let(:api)           { double 'API', :identifier => 'foo', :put => true }
  let(:action_class)  { double }
  let(:configuration) { double 'TS Configuration' }
  let(:setting_files) { double :to_hash => {'extra' => 'wordforms:txt.txt',
    'wordforms:txt.txt' => 'something'} }
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
  end

  def ungzip(contents)
    io     = StringIO.new contents, 'rb'
    reader = Zlib::GzipReader.new io
    reader.read
  end

  describe 'configure' do
    it 'sends data to the server' do
      api.should_receive(:put)

      controller.configure
    end

    it 'sends through gzipped configuration files' do
      api.should_receive(:put) do |path, options|
        path.should == 'configure'
        options[:configuration]['gzip'].should == 'true'
        ungzip(options[:configuration]['sphinx'].read).should == 'indexer ...'
        ungzip(options[:configuration]['wordforms:txt.txt'].read).should == 'something'
      end

      controller.configure
    end

    it 'sends through file if provided' do
      api.should_receive(:put).with 'configure',
        :configuration  => {'sphinx' => 'searchd ...'},
        :sphinx_version => '2.0.6'

      controller.configure 'searchd ...'
    end
  end
end
