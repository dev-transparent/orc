module Orc
  module Columns
    class FloatColumn < Column(Float32)
      @data_io : IO

      def initialize(@stripe : Stripe, @field : Field)
        super

        @data_io = data_stream.buffer
      end

      def next
        Float32.from_io(@data_io, IO::ByteFormat::BigEndian) if present?
      rescue IO::EOFError
        stop
      end
    end
  end
end