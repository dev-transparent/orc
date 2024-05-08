module Orc
  module Readers
    class FloatReader < Base(Float32)
      def initialize(@io : IO)
      end

      def next
        @io.read_bytes(Float32, IO::ByteFormat::LittleEndian)
      rescue IO::EOFError
        stop
      end
    end
  end
end