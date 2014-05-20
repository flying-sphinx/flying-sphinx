class FlyingSphinx::Configure::Uploader
  unless ENV['STAGED_SPHINX_API_KEY']
    SERVER = 'https://papyrus.flying-sphinx.com'
  else
    SERVER = 'https://papyrus-staging.flying-sphinx.com'
  end

  def call(options)
    path = path_for options
    md5  = cache.md5_for path
    return unless md5.nil? || (md5 != md5_for(options))

    contents = options[:contents] || File.read(options[:file])

    connection.put do |request|
      request.url "/#{path}"
      request.headers['Content-Type'] = 'application/gzip'
      request.body = FlyingSphinx::GZipper.encode contents
    end
  end

  private

  def cache
    @cache ||= FlyingSphinx::Configure::Cache.new connection
  end

  def configuration
    @configuration ||= FlyingSphinx::Configuration.new
  end

  def connection
    @connection ||= Faraday.new(:url => SERVER) do |builder|
      # Local middleware
      builder.use FlyingSphinx::Request::HMAC,
        configuration.identifier, configuration.api_key, 'Papyrus'
      builder.use FlyingSphinx::Response::Logger
      builder.use FlyingSphinx::Response::Invalid

      builder.adapter :net_http
    end
  end

  def path_for(options)
    options[:path] || File.join(options[:prefix].to_s,
      File.basename(options[:file]))
  end

  def md5_for(options)
    if options[:file]
      Digest::MD5.file(options[:file]).hexdigest
    else
      Digest::MD5.hexdigest options[:contents]
    end
  end
end
