require 'spec_helper'

describe FlyingSphinx::SettingFiles do
  let(:files)   { FlyingSphinx::SettingFiles.new configuration }
  let(:configuration) do
    double(:configuration, :indices => indices, :common => common)
  end
  let(:indices) { [] }
  let(:common)  { double(:common, :lemmatizer_base => nil) }

  def index_double(methods)
    double 'Riddle::Configuration::Index', methods
  end

  def source_double(methods)
    double 'Riddle::Configuration::SQLSource', methods
  end

  describe '#to_hash' do
    before :each do
      allow(File).to receive(:read).and_return('blah')
    end

    [:stopwords, :wordforms, :exceptions].each do |setting|
      it "collects #{setting} files from indices" do
        indices << index_double(setting => '/my/file/foo.txt')

        expect(files.to_hash).to eq(
          "#{setting}/foo.txt" => 'blah',
          'extra'              => "#{setting}/foo.txt"
        )
      end

      it "does not repeat same files for #{setting}" do
        indices << index_double(setting => '/my/file/foo.txt')
        indices << index_double(setting => '/my/file/foo.txt')

        expect(files.to_hash).to eq(
          "#{setting}/foo.txt" => 'blah',
          'extra'              => "#{setting}/foo.txt"
        )
      end

      it "accepts multiples files for #{setting}" do
        indices << index_double(
          setting => '/my/file/foo.txt /my/file/bar.txt')

        expect(files.to_hash["#{setting}/foo.txt"]).to eq('blah')
        expect(files.to_hash["#{setting}/bar.txt"]).to eq('blah')
        expect(files.to_hash['extra'].split(';')).to match_array([
          "#{setting}/foo.txt", "#{setting}/bar.txt"
        ])
      end
    end

    [:mysql_ssl_cert, :mysql_ssl_key, :mysql_ssl_ca].each do |setting|
      it "collects #{setting} files from sources" do
        indices << index_double(:sources => [
          source_double(setting => '/my/file/foo.txt')])

        expect(files.to_hash).to eq(
          "#{setting}/foo.txt" => 'blah',
          'extra'              => "#{setting}/foo.txt"
        )
      end

      it "does not repeat same files for #{setting}" do
        indices << index_double(:sources => [
          source_double(setting => '/my/file/foo.txt')])
        indices << index_double(:sources => [
          source_double(setting => '/my/file/foo.txt')])

        expect(files.to_hash).to eq(
          "#{setting}/foo.txt" => 'blah',
          'extra'              => "#{setting}/foo.txt"
        )
      end

      it "accepts multiples files for #{setting}" do
        indices << index_double(:sources => [
          source_double(setting => '/my/file/foo.txt /my/file/bar.txt')])

        expect(files.to_hash["#{setting}/foo.txt"]).to eq('blah')
        expect(files.to_hash["#{setting}/bar.txt"]).to eq('blah')
        expect(files.to_hash['extra'].split(';')).to match_array([
          "#{setting}/foo.txt", "#{setting}/bar.txt"
        ])
      end
    end

    [:lemmatizer_base].each do |setting|
      it "collects #{setting} files from sources" do
        allow(common).to receive(setting).and_return("/my/path")

        allow(Dir).to receive(:[]).with("/my/path/**/*").
          and_return(["/my/path/foo.txt"])

        expect(files.to_hash).to eq(
          "#{setting}/foo.txt" => 'blah',
          'extra'              => "#{setting}/foo.txt"
        )
      end
    end
  end
end
