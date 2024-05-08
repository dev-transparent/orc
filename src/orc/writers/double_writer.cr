require "./base"

module Orc
  module Writers
    class DoubleWriter < Base(Float64)
      def initialize(@io : IO)
      end

      def write(value : Float64)
        @io.write_bytes(value, IO::ByteFormat::LittleEndian)
      end

      def flush
        @writer.flush
      end
    end
  end
end