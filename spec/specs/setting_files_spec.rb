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

  describe '#to_hash' do
    before :each do
      File.stub :read => 'blah'
    end

    [:stopwords, :wordforms, :exceptions].each do |setting|
      it "uploads #{setting} files from indices" do
        indices << index_double(setting => '/my/file/foo.txt')

        files.to_hash.should == {
          "#{setting}:foo.txt" => 'blah',
          'extra'              => "#{setting}:foo.txt"
        }
      end

      it "does not repeat same files for #{setting}" do
        indices << index_double(setting => '/my/file/foo.txt')
        indices << index_double(setting => '/my/file/foo.txt')

        files.to_hash.should == {
          "#{setting}:foo.txt" => 'blah',
          'extra'              => "#{setting}:foo.txt"
        }
      end

      it "accepts multiples files for #{setting}" do
        indices << index_double(
          setting => '/my/file/foo.txt /my/file/bar.txt')

        files.to_hash.should == {
          "#{setting}:foo.txt" => 'blah',
          "#{setting}:bar.txt" => 'blah',
          'extra'              => "#{setting}:foo.txt;#{setting}:bar.txt"
        }
      end
    end

    [:mysql_ssl_cert, :mysql_ssl_key, :mysql_ssl_ca].each do |setting|
      it "uploads #{setting} files from indices" do
        indices << index_double(:sources => [
          source_double(setting => '/my/file/foo.txt')])

        files.to_hash.should == {
          "#{setting}:foo.txt" => 'blah',
          'extra'              => "#{setting}:foo.txt"
        }
      end

      it "does not repeat same files for #{setting}" do
        indices << index_double(:sources => [
          source_double(setting => '/my/file/foo.txt')])
        indices << index_double(:sources => [
          source_double(setting => '/my/file/foo.txt')])

        files.to_hash.should == {
          "#{setting}:foo.txt" => 'blah',
          'extra'              => "#{setting}:foo.txt"
        }
      end

      it "accepts multiples files for #{setting}" do
        indices << index_double(:sources => [
          source_double(setting => '/my/file/foo.txt /my/file/bar.txt')])

        files.to_hash.should == {
          "#{setting}:foo.txt" => 'blah',
          "#{setting}:bar.txt" => 'blah',
          'extra'              => "#{setting}:foo.txt;#{setting}:bar.txt"
        }
      end
    end
  end
end
