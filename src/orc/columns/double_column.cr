module Orc
  module Columns
    class DoubleColumn < Column(Float64)
      def next
        Float64.from_io(data_stream.buffer, IO::ByteFormat::BigEndian) if present?
      rescue IO::EOFError
        stop
      end
    end
  end
end