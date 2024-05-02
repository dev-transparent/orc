module Orc
  module Columns
    class IntegerColumn < Column(Int64)
      def initialize(encoding : Orc::Proto::ColumnEncoding, data_stream : Stream, present_stream : Stream? = nil)
        case encoding.kind
        when Orc::Proto::ColumnEncoding::Kind::DIRECT
          @data = RunLengthIntegerReader.new(data_stream.buffer, true)
        when Orc::Proto::ColumnEncoding::Kind::DIRECTV2
          @data = RunLengthIntegerReaderV2.new(data_stream.buffer, true)
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