module Orc
  abstract class Column(T)
    include Iterator(T | Nil)

    getter id : Int32
    getter streams : Array(Stream)
    getter encoding : Proto::ColumnEncoding

    @present_stream : Stream?
    @present_reader : RunLengthBooleanReader?

    def initialize(@id : Int32, @encoding : Proto::ColumnEncoding, @streams : Array(Stream))
    end

    def initialize(stripe : Stripe, field : Field)
      @id = field.id
      @encoding = stripe.column_encodings[field.id]
      @streams = stripe.streams.select { |stream| stream.column == field.id }
    end

    def data_stream : Stream
      streams.find! { |stream| stream.kind == Proto::Stream::Kind::DATA }
    end

    def present_stream : Stream
      @present_stream ||= streams.find! { |stream| stream.kind == Proto::Stream::Kind::PRESENT }
    end

    def present_reader : RunLengthBooleanReader?
      if stream = present_stream
        @present_reader ||= RunLengthBooleanReader.new(stream.buffer)
      end
    end

    def present?
      if reader = @present_reader
        reader.next
      else
        true
      end
    end
  end
end