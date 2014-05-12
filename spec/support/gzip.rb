module GZipHelpers
  def gzip(uncompressed)
    io = StringIO.new 'w'
    Zlib::GzipWriter.new(io).tap do |writer|
      writer.write uncompressed
      writer.close
    end
    io.string
  end

  def ungzip(compressed)
    io     = StringIO.new compressed, 'rb'
    reader = Zlib::GzipReader.new io
    reader.read
  end
end

RSpec.configure do |config|
  config.include GZipHelpers
end
