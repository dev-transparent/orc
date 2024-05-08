module Orc
  module Columns
    class BooleanColumn < Column(Bool)
      @reader : ColumnReader(Bool)?

      def reader
        @reader ||= case encoding.kind
        when Orc::Proto::ColumnEncoding::Kind::DIRECT
          ColumnReader(Bool).new(
            Readers::BooleanReader.new(RunLengthBooleanReader.new(data_stream.buffer)),
            present_reader
          )
        else
          raise "Encoding type #{encoding.kind} not supported"
        end
      end

      def next
        reader.next
      end
    end
  end
end