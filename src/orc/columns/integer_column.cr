module Orc
  module Columns
    class IntegerColumn < Column(Int64)
      @reader : RunLengthIntegerReader | RunLengthIntegerReaderV2 | Nil

      def reader
        @reader ||= case encoding.kind
        when Orc::Proto::ColumnEncoding::Kind::DIRECT
          RunLengthIntegerReader.new(data_stream.buffer, true)
        when Orc::Proto::ColumnEncoding::Kind::DIRECTV2
          RunLengthIntegerReaderV2.new(data_stream.buffer, true)
        else
          raise "Encoding type #{encoding.kind} not supported"
        end
      end

      def next
        reader.next if present?
      end
    end
  end
end