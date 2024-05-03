module Orc
  module Columns
    class StringColumn < Column(String)
      @reader : StringReader?

      def reader
        @reader ||= case encoding.kind
        when Orc::Proto::ColumnEncoding::Kind::DIRECT
          StringDirectReader.new(
            RunLengthIntegerReader.new(length_stream.buffer, false),
            data_stream.buffer
          )
        when Orc::Proto::ColumnEncoding::Kind::DICTIONARY
          StringDictionaryReader.new(
            RunLengthIntegerReader.new(length_stream.buffer, false),
            RunLengthIntegerReader.new(data_stream.buffer, false),
            dictionary_stream.buffer
          )
        else
          raise "Encoding type #{encoding.kind} not supported"
        end
      end

      def length_stream : Stream
        stripe.streams.find! { |stream| stream.kind == Proto::Stream::Kind::LENGTH && stream.column == field.id }
      end

      def dictionary_stream : Stream
        stripe.streams.find! { |stream| stream.kind == Proto::Stream::Kind::DICTIONARYDATA && stream.column == field.id }
      end

      def next
        return unless present?

        reader.next
      end
    end
  end
end
