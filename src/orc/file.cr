module Orc
  class File
    getter codec : Codec

    getter postscript : Orc::Proto::PostScript
    getter footer : Orc::Proto::Footer
    getter metadata : Orc::Proto::Metadata?

    getter schema : Orc::Schema

    private getter io : IO

    def initialize(@io : IO)
      byte_length = io.size
      offset = byte_length - 16_000
      offset = 0 if offset < 0
      offset_from_end = 0

      postscript_length_offset = byte_length - 1
      postscript_length = io.read_at(postscript_length_offset, 1) do |postscript_length_io|
        postscript_length_io.read_byte.not_nil!.to_i64
      end

      postscript_offset = postscript_length_offset - postscript_length
      @postscript = io.read_at(postscript_offset, postscript_length) do |postscript_io|
        Orc::Proto::PostScript.from_protobuf(postscript_io)
      end

      @codec = case postscript.compression
      when Orc::Proto::CompressionKind::NONE
        Orc::Codecs::None.new
      when Orc::Proto::CompressionKind::ZLIB
        Orc::Codecs::ZLib.new
      else
        raise "Unsupported codec #{postscript.compression}"
      end

      footer_offset = postscript_offset - postscript.footer_length.not_nil!
      @footer = io.read_at(footer_offset, postscript.footer_length.not_nil!) do |footer_io|
        Orc::Proto::Footer.from_protobuf(codec.decode(footer_io))
      end

      if metadata_length = postscript.metadata_length
        @metadata = io.read_at(footer_offset - metadata_length, metadata_length) do |metadata_io|
          Orc::Proto::Metadata.from_protobuf(metadata_io)
        end
      end

      @schema = Orc::Schema.new(footer.types.not_nil!)
    end
  end
end