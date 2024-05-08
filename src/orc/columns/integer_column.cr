module Orc
  module Columns
    class IntegerColumn < Column(Int64)
      @reader : ColumnReader(Int64)?

      def reader
        @reader ||= begin
          format = case encoding.kind
          when Orc::Proto::ColumnEncoding::Kind::DIRECT
            RunLengthIntegerReader.new(data_stream.buffer, true)
          when Orc::Proto::ColumnEncoding::Kind::DIRECTV2
            RunLengthIntegerReaderV2.new(data_stream.buffer, true)
          else
            raise "Encoding type #{encoding.kind} not supported"
          end

          ColumnReader.new(
            Readers::IntegerReader.new(format),
            present_reader
          )
        end
      end

      def next
        reader.next
      end
    end
  end
end