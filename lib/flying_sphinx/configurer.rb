class FlyingSphinx::Configurer
  PresignatureError = Class.new FlyingSphinx::Error
  UploadError = Class.new FlyingSphinx::Error

  def initialize(api, input = nil)
    @api   = api
    @input = input
  end

  def call
    if presignature["status"] != "OK"
      raise PresignatureError, "Requesting presignature failed"
    end

    response = connection.post "", fields.merge(
      "file" => Faraday::UploadIO.new(file, 'application/gzip', 'sphinx.tar.gz')
    )

    if response.status == 200
      presignature["path"]
    else
      raise UploadError, "Uploading configuration failed"
    end
  end

  private

  attr_reader :api, :input

  def connection
    Faraday.new(:url => presignature["url"]) do |builder|
      builder.request :multipart

      builder.use FlyingSphinx::Response::Logger

      builder.adapter Faraday.default_adapter
    end
  end

  def fields
    presignature["fields"] || {}
  end

  def file
    config = FlyingSphinx::ConfigurationOptions.new input
    writer = GZippedTar::Writer.new

    writer.add "sphinx/raw.conf",    config.raw
    writer.add "sphinx/version.txt", config.version
    writer.add "sphinx/extra.txt",   config.settings["extra"]

    config.settings["extra"].split(";").each do |key|
      writer.add key, config.settings[key]
    end unless config.settings["extra"].blank?

    StringIO.new writer.output
  end

  def presignature
    @presignature ||= api.get "/presignature"
  end
end
