require 'light_spec_helper'
require 'flying_sphinx/setting_files'

describe FlyingSphinx::SettingFiles do
  let(:files)   { FlyingSphinx::SettingFiles.new indices }
  let(:indices) { [] }

  def index_double(methods)
    fire_double 'Riddle::Configuration::Index', methods
  end

  def source_double(methods)
    fire_double 'Riddle::Configuration::SQLSource', methods
  end

  describe '#upload_to' do
    let(:api) { fire_double('FlyingSphinx::API') }

    before :each do
      File.stub :read => 'blah'
    end

    [:stopwords, :wordforms, :exceptions].each do |setting|
      it "uploads #{setting} files from indices" do
        indices << index_double(setting => '/my/file/foo.txt')

        api.should_receive(:post).with('/add_file', :setting => setting.to_s,
          :file_name => 'foo.txt', :content => 'blah')

        files.upload_to(api)
      end

      it "does not repeat same files for #{setting}" do
        indices << index_double(setting => '/my/file/foo.txt')
        indices << index_double(setting => '/my/file/foo.txt')

        api.should_receive(:post).with('/add_file', :setting => setting.to_s,
          :file_name => 'foo.txt', :content => 'blah').once

        files.upload_to(api)
      end

      it "accepts multiples files for #{setting}" do
        indices << index_double(
          setting => '/my/file/foo.txt /my/file/bar.txt')

        api.should_receive(:post).with('/add_file', :setting => setting.to_s,
          :file_name => 'foo.txt', :content => 'blah').once
        api.should_receive(:post).with('/add_file', :setting => setting.to_s,
          :file_name => 'bar.txt', :content => 'blah').once

        files.upload_to(api)
      end
    end

    [:mysql_ssl_cert, :mysql_ssl_key, :mysql_ssl_ca].each do |setting|
      it "uploads #{setting} files from indices" do
        indices << index_double(:sources => [
          source_double(setting => '/my/file/foo.txt')])

        api.should_receive(:post).with('/add_file', :setting => setting.to_s,
          :file_name => 'foo.txt', :content => 'blah')

        files.upload_to(api)
      end

      it "does not repeat same files for #{setting}" do
        indices << index_double(:sources => [
          source_double(setting => '/my/file/foo.txt')])
        indices << index_double(:sources => [
          source_double(setting => '/my/file/foo.txt')])

        api.should_receive(:post).with('/add_file', :setting => setting.to_s,
          :file_name => 'foo.txt', :content => 'blah').once

        files.upload_to(api)
      end

      it "accepts multiples files for #{setting}" do
        indices << index_double(:sources => [
          source_double(setting => '/my/file/foo.txt /my/file/bar.txt')])

        api.should_receive(:post).with('/add_file', :setting => setting.to_s,
          :file_name => 'foo.txt', :content => 'blah').once
        api.should_receive(:post).with('/add_file', :setting => setting.to_s,
          :file_name => 'bar.txt', :content => 'blah').once

        files.upload_to(api)
      end
    end
  end
end
