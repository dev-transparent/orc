module Orc
  module Columns
    class ByteColumn < Column(UInt8)
      @reader : RunLengthByteReader?

      def reader
        @reader ||= case encoding.kind
        when Orc::Proto::ColumnEncoding::Kind::DIRECT
          RunLengthByteReader.new(data_stream.buffer)
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