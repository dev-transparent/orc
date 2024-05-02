module Orc
  class Writer
    private getter io : IO
    private getter footer_buffer : IO::Memory
    private getter postscript_buffer : IO::Memory

    def initialize(@schema : Schema, @io : IO)
      write_header

      @footer_buffer = IO::Memory.new
      @postscript_buffer = IO::Memory.new
    end

    def write_header
      io.write("ORC".to_slice)
    end

    def write_batch(batch : Batch)
    end

    def write_footer
      footer = Orc::Proto::Footer.new(
        header_length: 3,
        # content_length: 0, # TODO: Content length in bytes
        # stripes: StripeInformation,
        # types: Type,
        # metadata: UserMetadataItem,
        # number_of_rows: :uint64,
        # statistics: ColumnStatistics,
        # row_index_stride: :uint32,
        # writer: 6,
        # software_version: :string,
      )

      footer.to_protobuf(IO::MultiWriter.new(footer_buffer, io))
      write_postscript
    end

    private def write_postscript
      postscript = Orc::Proto::PostScript.new(
        footer_length: footer_buffer.size.to_u64,
        compression: Orc::Proto::CompressionKind::NONE,
        # compression_block_size: :uint64,
        # version: :uint32,
        # metadata_length: :uint64,
        # writer_version: :uint32,
        # stripe_statistics_length: :uint64,
        magic: "ORC",
      )

      postscript.to_protobuf(IO::MultiWriter.new(postscript_buffer, io))
      io.write_byte(postscript_buffer.size.to_u8)
    end
  end
end