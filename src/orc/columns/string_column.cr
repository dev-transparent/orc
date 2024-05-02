module Orc
  module Columns
    class StringColumn < Column(String)
      def initialize(encoding : Orc::Proto::ColumnEncoding, data_stream : Stream, length_stream : Stream, present_stream : Stream? = nil)
        case encoding.kind
        when Orc::Proto::ColumnEncoding::Kind::DIRECT
          @length = RunLengthIntegerReader.new(length_stream.buffer, false)
        else
          raise "Encoding type #{encoding.kind} not supported"
        end

        @data_io = data_stream.buffer

        if present_stream
          @present = RunLengthBooleanReader.new(present_stream.buffer)
        end
      end

      def next
        return unless present?

        case length = @length.next
        when Int64
          bytes = Bytes.new(length)
          @data_io.read(bytes)

          String.new(bytes)
        when Iterator::Stop
          stop
        end
      end
    end
  end
end
