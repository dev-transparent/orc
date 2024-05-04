module Orc
  class Writer
    private getter io : IO
    private getter footer_buffer : IO::Memory = IO::Memory.new
    private getter postscript_buffer : IO::Memory = IO::Memory.new

    private getter stripes : Array(Stripe) = [] of Stripe

    def initialize(@io : IO)
      write_header

      yield self

      write_footer
    end

    def write_stripe(stripe : Stripe)
      stripe.to_io(io)
      stripes << stripe
    end

    private def write_header
      io.write("ORC".to_slice)
    end

    private def write_footer
      footer = Orc::Proto::Footer.new(
        header_length: 3,
        stripes: stripe_information,
        content_length: stripe_information.sum { |info| info.index_length.not_nil! + info.data_length.not_nil! + info.footer_length.not_nil! },
        types: types,
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

    private def types : Array(Orc::Proto::Type)
      [
        Orc::Proto::Type.new(
          kind: Orc::Proto::Type::Kind::STRUCT,
          subtypes: [1u32],
          field_names: ["Boolean"]
          #     optional :maximum_length, :uint32, 4
          #     optional :precision, :uint32, 5
          #     optional :scale, :uint32, 6
          #     repeated :attributes, StringPair, 7
        ),
        Orc::Proto::Type.new(
          kind: Orc::Proto::Type::Kind::BOOLEAN,
          subtypes: [] of UInt32,
          field_names: [] of String
        )
      ]
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