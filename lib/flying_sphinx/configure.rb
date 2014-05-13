class FlyingSphinx::Configure
  unless ENV['STAGED_SPHINX_API_KEY']
    SERVER = 'https://papyrus.flying-sphinx.com'
  else
    SERVER = 'https://papyrus-staging.flying-sphinx.com'
  end

  def initialize(contents = nil)
    @contents = contents || FlyingSphinx.translator.sphinx_configuration
  end

  def call
    update_contents 'sphinx/config.conf', contents
    update_contents 'sphinx/version.txt', version

    settings.each_file_for_setting { |setting, file| update_file setting, file }
  end

  private

  attr_reader :contents

  def cache
    @cache ||= MultiJson.load connection.get('/').body
  end

  def cached_md5(path)
    file = cache.detect { |file| file['key'] == path }
    file && file['md5']
  end

  def configuration
    @configuration ||= FlyingSphinx::Configuration.new
  end

  def connection
    @connection ||= Faraday.new(:url => SERVER) do |builder|
      # Digest authentication
      builder.request :digest, configuration.identifier, configuration.api_key

      # Local middleware
      builder.use FlyingSphinx::Response::Logger
      builder.use FlyingSphinx::Response::Invalid

      builder.adapter :net_http
    end
  end

  def gzip(string)
    io = StringIO.new 'w'
    Zlib::GzipWriter.new(io).tap do |writer|
      writer.write string
      writer.close
    end
    io.string
  end

  def settings
    FlyingSphinx::SettingFiles.new
  end

  def thinking_sphinx
    ThinkingSphinx::Configuration.instance
  end

  def update_contents(path, contents)
    connection.put do |request|
      request.url "/#{path}"
      request.headers['Content-Type'] = 'application/gzip'
      request.body = gzip(contents)
    end unless cached_md5(path) == Digest::MD5.hexdigest(contents)
  end

  def update_file(prefix, file)
    path = File.join prefix, File.basename(file)

    connection.put do |request|
      request.url "/#{path}"
      request.headers['Content-Type'] = 'application/gzip'
      request.body = gzip File.read(file)
    end unless cached_md5(path) == Digest::MD5.file(file).hexdigest
  end

  def version
    version_defined? ? thinking_sphinx.version : '2.1.4'
  end

  def version_defined?
    thinking_sphinx.respond_to?(:version) && thinking_sphinx.version.present?
  end
end
