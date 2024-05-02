module Orc
  class Stripe
    getter info : Proto::StripeInformation
    getter footer : Orc::Proto::StripeFooter
    getter column_encodings : Array(Orc::Proto::ColumnEncoding)

    private getter reader : Reader

    @streams : Array(Stream)?

    delegate io, to: reader

    def initialize(@reader : Reader, @info : Proto::StripeInformation)
      footer_offset = @info.offset.not_nil! + @info.index_length.not_nil! + @info.data_length.not_nil!

      @footer = io.read_at(footer_offset, @info.footer_length.not_nil!) do |stripe_footer_io|
        Orc::Proto::StripeFooter.from_protobuf(stripe_footer_io)
      end

      @column_encodings = @footer.columns.not_nil!
    end

    def streams
      @streams ||= begin
        # Skip to the start of the stripe block
        io.seek(info.offset.not_nil!)

        @footer.streams.not_nil!.map do |stream|
          Stream.new(
            reader: reader,
            column: stream.column.not_nil!,
            length: stream.length.not_nil!,
            kind: stream.kind.not_nil!,
          )
        end
      end
    end
  end
end