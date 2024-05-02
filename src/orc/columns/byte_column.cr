module Orc
  module Columns
    class ByteColumn < Column(UInt8)
      def initialize(@stripe : Stripe, @field : Field)
        super

        case encoding.kind
        when Orc::Proto::ColumnEncoding::Kind::DIRECT
          @data = RunLengthByteReader.new(data_stream.buffer)
        else
          raise "Encoding type #{encoding.kind} not supported"
        end
      end

      def next
        @data.next if present?
      end
    end
  end
end