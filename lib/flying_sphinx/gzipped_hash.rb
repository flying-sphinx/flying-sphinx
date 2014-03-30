require 'zlib'

class FlyingSphinx::GzippedHash
  def initialize(hash)
    @hash = hash
  end

  def to_gzipped_hash
    hash['gzip'] = 'true'

    keys.each { |key| hash[key] = gzip hash[key] }

    hash
  end

  private

  attr_reader :hash

  def keys
    keys = (hash['extra'] || '').split(';')
    keys << 'sphinx' if hash['sphinx']
    keys
  end

  def gzip(string)
    io     = StringIO.new 'w'
    writer = Zlib::GzipWriter.new io
    writer.write string
    writer.close
    Faraday::UploadIO.new StringIO.new(io.string, 'rb'), 'application/gzip'
  end
end
