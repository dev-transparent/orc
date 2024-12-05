module Orc
  class Writer
    HEADER_BYTES = "ORC".to_slice

    private getter io : IO
    private getter schema : Schema

    property footer : Proto::Footer
    property postscript : Proto::PostScript

    delegate flush, close, to: io

    def initialize(@io : IO, @schema : Schema)
      @footer = Proto::Footer.new(
        header_length: 3u64,
        content_length: 0.to_u64, # TODO: Add content length so reader can determine how to allocate memory
        stripes: [] of Proto::StripeInformation,
        types: schema.to_protobuf,
        number_of_rows: 0u64
      )

      @postscript = Proto::PostScript.new(
        footer_length: 0.to_u64
      )

      write_header
    end

    def write_stripe(stripe)
      stripe_offset = io.pos

      streams = stripe.columns.flat_map do |column|
        column.streams.to_a.compact_map do |stream|
          next unless stream

          # Flush every stream and writer to the underlying memory to ensure bytesize is correct
          stream.flush

          Proto::Stream.new(
            kind: stream.kind,
            column: column.id,
            length: stream.bytesize.to_u64
          )
        end
      end

      column_encodings = stripe.columns.map do |column|
        column.encoding
      end

      stripe_footer = Proto::StripeFooter.new(
        streams: streams,
        columns: [Proto::ColumnEncoding.new(kind: Proto::ColumnEncoding::Kind::DIRECT)] + column_encodings
      )

      stripe.columns.each do |column|
        column.streams.each do |stream|
          next unless stream

          stream.to_io(io)
        end
      end

      data_length = io.pos - stripe_offset

      # Record the stripe footer
      initial_pos = io.pos
      stripe_footer = stripe_footer.to_protobuf(io)
      footer_length = io.pos - initial_pos

      # Add stripe information for footer
      footer.stripes.not_nil! << Proto::StripeInformation.new(
        offset: stripe_offset.to_u64,
        index_length: 0.to_u64,
        data_length: data_length.to_u64,
        footer_length: footer_length.to_u64,
        number_of_rows: stripe.rows,
      )

      footer.number_of_rows = footer.number_of_rows.not_nil! + stripe.rows

      io.flush
    end

    private def write_header
      io.write(HEADER_BYTES)
    end

    def write_footer
      footer_bytes = @footer.to_protobuf.to_slice

      @io.write(footer_bytes)
      @postscript.footer_length = footer_bytes.size.to_u64

      write_postscript
    end

    private def write_postscript
      postscript_bytes = @postscript.to_protobuf.to_slice

      @io.write(postscript_bytes)
      @io.write_byte(postscript_bytes.size.to_u8)
    end
  end
end