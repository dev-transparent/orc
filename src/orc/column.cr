module Orc
  abstract class Column(T)
    include Iterator(T | Nil)

    getter stripe : Stripe
    getter field : Field
    getter encoding : Proto::ColumnEncoding

    @present_stream : Stream?
    @present : RunLengthBooleanReader?

    def initialize(@stripe : Stripe, @field : Field)
      @encoding = stripe.column_encodings[field.id]

      @present_stream = @stripe.streams.find { |stream| stream.kind == Proto::Stream::Kind::PRESENT && stream.column == field.id }

      if stream = @present_stream
        @present = RunLengthBooleanReader.new(stream.buffer)
      end
    end

    def data_stream : Stream
      stripe.streams.find! { |stream| stream.kind == Proto::Stream::Kind::DATA && stream.column == field.id }
    end

    def present?
      if reader = @present
        reader.next
      else
        true
      end
    end
  end
end