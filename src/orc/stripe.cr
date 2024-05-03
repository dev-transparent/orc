module Orc
  class Stripe
    getter io : IO
    getter streams : Array(Stream)
    getter info : Proto::StripeInformation
    getter footer : Orc::Proto::StripeFooter
    getter column_encodings : Array(Orc::Proto::ColumnEncoding)

    def initialize(@io : IO, @streams : Array(Stream), @info : Proto::StripeInformation, @footer : Orc::Proto::StripeFooter)
      @column_encodings = @footer.columns.not_nil!
    end

    def self.from_reader(reader : Reader, info : Proto::StripeInformation)
      footer_offset = info.offset.not_nil! + info.index_length.not_nil! + info.data_length.not_nil!
      footer = reader.io.read_at(footer_offset, info.footer_length.not_nil!) do |stripe_footer_io|
        Orc::Proto::StripeFooter.from_protobuf(stripe_footer_io)
      end

      reader.io.seek(info.offset.not_nil!)

      streams = footer.streams.not_nil!.map do |stream|
        Stream.from_reader(
          reader: reader,
          column: stream.column.not_nil!,
          length: stream.length.not_nil!,
          kind: stream.kind.not_nil!,
        )
      end

      new(reader.io, streams, info, footer)
    end
  end
end