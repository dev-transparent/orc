require "./base"

module Orc
  module Writers
    class FloatWriter < Base(Float32)
      def initialize(@io : IO)
      end

      def write(value : Float32)
        @io.write_bytes(value, IO::ByteFormat::LittleEndian)
      end

      def flush
        @writer.flush
      end
    end
  end
end