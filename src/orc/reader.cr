module Orc
  class Reader
    TAIL_SIZE = 16 * 1024

    getter file : File

    property footer : Proto::Footer
    property postscript : Proto::PostScript
    property schema : Orc::Schema

    def initialize(@file : File)
      file_size = file.size

      # Calculate file offset
      offset = (file_size - TAIL_SIZE).clamp(0, file_size)

      # Take a slice of IO at the end of the file
      tail_bytes = file.read_at(offset, TAIL_SIZE.clamp(0, file_size)) do |io|
        io.getb_to_end
      end

      postscript_length = tail_bytes.last
      postscript_bytes = tail_bytes[-postscript_length.to_i - 1, postscript_length.to_i]
      @postscript = Orc::Proto::PostScript.from_protobuf(IO::Memory.new(postscript_bytes))

      footer_length = postscript.footer_length.not_nil!
      footer_bytes = tail_bytes[-postscript_length.to_i - footer_length.to_i - 1, footer_length.to_i]
      @footer = Orc::Proto::Footer.from_protobuf(IO::Memory.new(footer_bytes))

      @schema = Schema.from_footer(footer)
    end

    def each_stripe
      StripeIterator.new(self)
    end
  end
end
