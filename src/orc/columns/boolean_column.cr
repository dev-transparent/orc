module Orc
  module Columns
    class BooleanColumn < Column(Bool)
      @reader : RunLengthBooleanReader?

      def reader
        @reader ||= case encoding.kind
        when Orc::Proto::ColumnEncoding::Kind::DIRECT
          RunLengthBooleanReader.new(data_stream.buffer)
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