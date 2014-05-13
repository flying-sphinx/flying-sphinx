require 'zlib'

module FlyingSphinx::GZipper
  def self.encode(uncompressed)
    io = StringIO.new 'w'
    Zlib::GzipWriter.new(io).tap do |writer|
      writer.write uncompressed
      writer.close
    end
    io.string
  end

  def self.decode(compressed)
    io     = StringIO.new compressed, 'rb'
    reader = Zlib::GzipReader.new io
    reader.read
  end
end
