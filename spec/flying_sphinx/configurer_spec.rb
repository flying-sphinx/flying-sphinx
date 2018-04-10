require "spec_helper"

RSpec.describe FlyingSphinx::Configurer do
  let(:subject) { FlyingSphinx::Configurer.new api }
  let(:api)     { double :get => presignature }
  let(:presignature) { {
    "status" => "OK",
    "path"   => "a/path/of/my/own",
    "url"    => "https://confserver",
    "fields" => {"message" => "something"}
  } }
  let(:configuration_options) { double "conf options", :version => "2.2.3",
    :raw => "indexer ...", :settings => settings, :engine => "manticore" }
  let(:settings) { {
    "extra"             => "wordforms/txt.txt",
    "wordforms/txt.txt" => "something"
  } }

  before :each do
    stub_request(:post, "https://confserver").to_return(:status => 200)

    allow(FlyingSphinx::ConfigurationOptions).to receive(:new).
      and_return(configuration_options)
  end

  it "requests a presignature path" do
    expect(api).to receive(:get).with("/presignature").and_return(presignature)

    subject.call
  end

  it "uploads a file to the presignature path" do
    subject.call

    expect(
      a_multipart_request(:post, 'https://confserver')
    ).to have_been_made
  end

  it "includes the configuration in the file" do
    subject.call

    expect(
      a_multipart_request(:post, "https://confserver").
      with_file { |contents|
        reader = GZippedTar::Reader.new contents
        reader.read("sphinx/raw.conf") == "indexer ..."
      }
    ).to have_been_made
  end

  it "includes the Sphinx version in the file" do
    subject.call

    expect(
      a_multipart_request(:post, "https://confserver").
      with_file { |contents|
        reader = GZippedTar::Reader.new contents
        reader.read("sphinx/version.txt") == "2.2.3"
      }
    ).to have_been_made
  end

  it "includes the Sphinx engine in the file" do
    subject.call

    expect(
      a_multipart_request(:post, "https://confserver").
      with_file { |contents|
        reader = GZippedTar::Reader.new contents
        reader.read("sphinx/engine.txt") == "manticore"
      }
    ).to have_been_made
  end

  it "includes the extra settings in the file" do
    subject.call

    expect(
      a_multipart_request(:post, "https://confserver").
      with_file { |contents|
        reader = GZippedTar::Reader.new contents
        reader.read("wordforms/txt.txt") == "something"
      }
    ).to have_been_made
  end

  it "includes the extra summary in the file" do
    subject.call

    expect(
      a_multipart_request(:post, "https://confserver").
      with_file { |contents|
        reader = GZippedTar::Reader.new contents
        reader.read("sphinx/extra.txt") == "wordforms/txt.txt"
      }
    ).to have_been_made
  end

  it "includes the provided fields in the request" do
    subject.call

    expect(
      a_multipart_request(:post, "https://confserver").
      with_params { |params| params["message"] == "something" }
    ).to have_been_made
  end

  it "returns the presignature path" do
    expect(subject.call).to eq("a/path/of/my/own")
  end

  context "presignature failure" do
    before :each do
      presignature["status"] = "failure"
    end

    it "raises a PresignatureError exception" do
      expect { subject.call }.to raise_error(
        FlyingSphinx::Configurer::PresignatureError
      )
    end

    it "does not attempt to upload" do
      begin
        subject.call
      rescue FlyingSphinx::Configurer::PresignatureError
      end

      expect(
        a_multipart_request(:post, "https://confserver")
      ).not_to have_been_made
    end
  end

  context "upload failure" do
    before :each do
      stub_request(:post, "https://confserver").to_return(:status => 400)
    end

    it "raises an UploadError exception" do
      expect { subject.call }.to raise_error(
        FlyingSphinx::Configurer::UploadError
      )
    end
  end
end
