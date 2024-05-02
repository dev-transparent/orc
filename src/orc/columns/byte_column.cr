module Orc
  module Columns
    class ByteColumn < Column(UInt8)
      def initialize(encoding : Orc::Proto::ColumnEncoding, data_stream : Stream, present_stream : Stream? = nil)
        case encoding.kind
        when Orc::Proto::ColumnEncoding::Kind::DIRECT
          @data = RunLengthByteReader.new(data_stream.buffer)
        else
          raise "Encoding type #{encoding.kind} not supported"
        end

        if present_stream
          @present = RunLengthBooleanReader.new(present_stream.buffer)
        end
      end

      def next
        @data.next if present?
      end
    end
  end
end