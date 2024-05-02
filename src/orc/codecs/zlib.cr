require "compress/zlib"

module Orc
  module Codecs
    class ZLib < Codec
      def encode(io : IO) : IO
        Compress::Zlib::Writer.new(io)
      end

      def decode(io : IO) : IO
        header = Bytes.new(4)
        io.read(header[0...3])

        value = IO::ByteFormat::LittleEndian.decode(UInt32, header)
        original = value % 2 == 1
        length = (value / 2).to_i

        if original
          IO::Sized.new(io, length)
        else
          Compress::Zlib::Reader.new(IO::Sized.new(io, length))
        end
      end
    end
  end
end