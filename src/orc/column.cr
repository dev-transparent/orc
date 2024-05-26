module Orc
  abstract class BaseColumn
  end

  abstract class Column(T) < BaseColumn
    include Iterator(T | Nil)

    getter id : Int32
    getter rows : Int32
    getter streams : Array(Stream)
    getter encoding : Proto::ColumnEncoding

    @present_stream : Stream?
    @present_reader : RunLengthBooleanReader?

    def initialize(@id : Int32, @encoding : Proto::ColumnEncoding, @streams : Array(Stream), @rows : Int32 = 0)
    end

    def initialize(stripe : Stripe, field : Field)
      @id = field.id
      @rows = stripe.number_of_rows.to_i32
      @encoding = stripe.column_encodings[field.id]
      @streams = stripe.streams.select { |stream| stream.column == field.id }
    end

    def data_stream : Stream
      streams.find! { |stream| stream.kind == Proto::Stream::Kind::DATA }
    end

    def present_stream : Stream?
      @present_stream ||= streams.find { |stream| stream.kind == Proto::Stream::Kind::PRESENT }
    end

    def present_stream! : Stream
      present_stream.not_nil!
    end

    def length_stream : Stream
      streams.find! { |stream| stream.kind == Proto::Stream::Kind::LENGTH }
    end

    def dictionary_stream : Stream
      streams.find! { |stream| stream.kind == Proto::Stream::Kind::DICTIONARYDATA }
    end

    def present_writer : RunLengthBooleanWriter
      @present_writer ||= RunLengthBooleanWriter.new(present_stream.buffer)
    end

    def present_reader : RunLengthBooleanReader?
      if stream = present_stream
        @present_reader ||= RunLengthBooleanReader.new(stream.buffer)
      end
    end
  end
end