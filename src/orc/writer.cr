module Orc
  class Writer
    private getter io : IO
    private getter footer_buffer : IO::Memory = IO::Memory.new
    private getter postscript_buffer : IO::Memory = IO::Memory.new

    private getter stripes : Array(Stripe) = [] of Stripe

    delegate flush, close, to: io

    def initialize(@io : IO)
    end

    def write_header
      io.write("ORC".to_slice)
    end

    def write_stripe(stripe : Stripe)
      stripe.to_io(io)
      stripes << stripe
    end

    def write_footer(schema : Schema)
      footer = Orc::Proto::Footer.new(
        header_length: 3,
        stripes: stripe_information,
        content_length: stripe_information.sum { |info| info.index_length.not_nil! + info.data_length.not_nil! + info.footer_length.not_nil! },
        types: schema.types,
        # metadata: UserMetadataItem,
        number_of_rows: stripes.sum(&.number_of_rows),
        # statistics: ColumnStatistics,
        # row_index_stride: :uint32,
        # writer: 6,
        # software_version: :string,
      )

      footer.to_protobuf(IO::MultiWriter.new(footer_buffer, io))
      write_postscript
    end

    private def stripe_information : Array(Orc::Proto::StripeInformation)
      offset = 3u64
      stripes.map do |stripe|
        Orc::Proto::StripeInformation.new(
          offset: offset,
          index_length: stripe.streams.select(&.index?).sum { |stream| stream.buffer.bytesize.to_u64 },
          data_length: stripe.streams.select(&.data?).sum { |stream| stream.buffer.bytesize.to_u64 },
          footer_length: stripe.footer.to_protobuf.size.to_u64, # TODO: Do something about the re-encoding of the footer
          number_of_rows: stripe.number_of_rows
        ).tap do |info|
          offset += info.index_length.not_nil! + info.data_length.not_nil! + info.footer_length.not_nil!
        end
      end
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