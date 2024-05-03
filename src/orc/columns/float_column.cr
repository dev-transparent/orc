module Orc
  module Columns
    class FloatColumn < Column(Float32)
      def next
        Float32.from_io(data_stream.buffer, IO::ByteFormat::BigEndian) if present?
      rescue IO::EOFError
        stop
      end
    end
  end
end