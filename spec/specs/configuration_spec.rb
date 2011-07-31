require 'spec_helper'
require 'multi_json'

describe FlyingSphinx::Configuration do
  let(:api_server) { 'https://flying-sphinx.com/api/my' }
  
  before :each do
    FakeWeb.register_uri(:get, "#{api_server}/app",
      :body => MultiJson.encode(
        :server        => 'foo.bar.com',
        :port          => 9319,
        :database_port => 10001
      )
    )
  end
  
  describe '#initialize' do
    let(:api_key)    { 'foo-bar-baz' }
    let(:identifier) { 'app@heroku.com' }
    let(:config)     { FlyingSphinx::Configuration.new identifier, api_key }
    
    it "requests details from the server with the given API key" do
      config
      FakeWeb.should have_requested :get, "#{api_server}/app"
    end
    
    it "sets the host from the server information" do
      config.host.should == 'foo.bar.com'
    end
    
    it "sets the port from the server information" do
      config.port.should == 9319
    end
    
    it "sets the port from the server information" do
      config.database_port.should == 10001
    end
  end
  
  describe '#file_setting_pairs' do
    let(:config)    { FlyingSphinx::Configuration.new 'ident' }
    let(:riddle)    { ThinkingSphinx::Configuration.instance.configuration }
    let(:base_path) { '/mnt/sphinx/flying-sphinx/ident' }
    
    context 'index setting' do
      it "pairs each local file path to a server file path" do
        riddle.stub! :indexes => [
          double('index', :wordforms => '/path/to/wordforms-foo.txt',
            :sources => [double('source'), double('source')]),
          double('index', :wordforms => '/path/to/wordforms-bar.txt',
            :sources => [double('source'), double('source')])
        ]
        
        config.file_setting_pairs(:wordforms).should == {
          '/path/to/wordforms-foo.txt' => "#{base_path}/wordforms/0.txt",
          '/path/to/wordforms-bar.txt' => "#{base_path}/wordforms/1.txt"
        }
      end
      
      it "doesn't duplicate multiple references to the same local file" do
        riddle.stub! :indexes => [
          double('index', :wordforms => '/path/to/wordforms-foo.txt',
            :sources => [double('source'), double('source')]),
          double('index', :wordforms => '/path/to/wordforms-foo.txt',
            :sources => [double('source'), double('source')])
        ]
        
        config.file_setting_pairs(:wordforms).should == {
          '/path/to/wordforms-foo.txt' => "#{base_path}/wordforms/0.txt"
        }
      end
    end
    
    context 'source setting' do
      it "pairs each local file path to a server file path" do
        riddle.stub! :indexes => [
          double('index', :sources => [
            double('source', :mysql_ssl_cert => '/path/to/cert-foo.txt'),
            double('source', :mysql_ssl_cert => '/path/to/cert-bar.txt')
          ]),
          double('index', :sources => [
            double('source', :mysql_ssl_cert => '/path/to/cert-baz.txt'),
            double('source', :mysql_ssl_cert => nil)
          ])
        ]
        
        config.file_setting_pairs(:mysql_ssl_cert).should == {
          '/path/to/cert-foo.txt' => "#{base_path}/mysql_ssl_cert/0.txt",
          '/path/to/cert-bar.txt' => "#{base_path}/mysql_ssl_cert/1.txt",
          '/path/to/cert-baz.txt' => "#{base_path}/mysql_ssl_cert/2.txt"
        }
      end
      
      it "doesn't duplicate multiple references to the same local file" do
        riddle.stub! :indexes => [
          double('index', :sources => [
            double('source', :mysql_ssl_cert => '/path/to/cert-foo.txt'),
            double('source', :mysql_ssl_cert => '/path/to/cert-bar.txt')
          ]),
          double('index', :sources => [
            double('source', :mysql_ssl_cert => '/path/to/cert-foo.txt'),
            double('source', :mysql_ssl_cert => nil)
          ])
        ]
        
        config.file_setting_pairs(:mysql_ssl_cert).should == {
          '/path/to/cert-foo.txt' => "#{base_path}/mysql_ssl_cert/0.txt",
          '/path/to/cert-bar.txt' => "#{base_path}/mysql_ssl_cert/1.txt"
        }
      end
    end
  end
  
  describe '#sphinx_configuration' do
    let(:config)    { FlyingSphinx::Configuration.new 'ident' }
    let(:riddle)    { double('riddle configuration', :render => '',
      :searchd => double('searchd').as_null_object,
      :indexer => double('indexer').as_null_object) }
    let(:base_path) { '/mnt/sphinx/flying-sphinx/ident' }
    let(:source)    { double('source') }
    
    before :each do
      ThinkingSphinx::Configuration.instance.stub!(
        :generate      => nil,
        :configuration => riddle
      )
      FlyingSphinx::Tunnel.stub! :required? => false
    end
    
    it "sets database settings to match Flying Sphinx port forward" do
      FlyingSphinx::Tunnel.stub! :required? => true
      
      riddle.stub! :indexes => [
        double('distributed index'),
        double('index', :sources => [source])
      ]
      
      source.should_receive(:sql_host=).with('127.0.0.1')
      source.should_receive(:sql_port=).with(10001)
      
      config.sphinx_configuration
    end
    
    it "sets file path to match server directories for index settings" do
      riddle.stub! :indexes => [
        double('index', :wordforms => '/path/to/wordforms-foo.txt',
          :sources => [double('source'), double('source')]),
        double('index', :wordforms => '/path/to/wordforms-bar.txt',
          :sources => [double('source'), double('source')])
      ]
      
      riddle.indexes[0].should_receive(:wordforms=).
        with("#{base_path}/wordforms/0.txt")
      riddle.indexes[1].should_receive(:wordforms=).
        with("#{base_path}/wordforms/1.txt")
      
      config.sphinx_configuration
    end
    
    it "sets file path to match server directories for source settings" do
      riddle.stub! :indexes => [
        double('index', :sources => [
          double('source', :mysql_ssl_cert => '/path/to/cert-foo.txt'),
          double('source', :mysql_ssl_cert => '/path/to/cert-bar.txt')
        ]),
        double('index', :sources => [
          double('source', :mysql_ssl_cert => '/path/to/cert-baz.txt'),
          double('source', :mysql_ssl_cert => nil)
        ])
      ]
      
      riddle.indexes[0].sources[0].should_receive(:mysql_ssl_cert=).
        with("#{base_path}/mysql_ssl_cert/0.txt")
      riddle.indexes[0].sources[1].should_receive(:mysql_ssl_cert=).
        with("#{base_path}/mysql_ssl_cert/1.txt")
      riddle.indexes[1].sources[0].should_receive(:mysql_ssl_cert=).
        with("#{base_path}/mysql_ssl_cert/2.txt")
      riddle.indexes[1].sources[1].should_receive(:mysql_ssl_cert=).
        with(nil)
      
      config.sphinx_configuration
    end
  end
end
