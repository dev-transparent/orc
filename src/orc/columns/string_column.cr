module Orc
  module Columns
    class StringColumn < Column(String)
      @reader : ColumnReader(String)?

      def next
        reader.next
      end

      def reader
        @reader ||= begin
          format = case encoding.kind
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

          ColumnReader.new(
            Readers::StringReader.new(format),
            present_reader
          )
        end
      end
    end
  end
end
