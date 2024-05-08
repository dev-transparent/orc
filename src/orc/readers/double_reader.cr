module Orc
  module Readers
    class DoubleReader < Base(Float64)
      def initialize(@io : IO)
      end

      def next
        Float64.from_io(@io, IO::ByteFormat::BigEndian)
      rescue IO::EOFError
        stop
      end
    end
  end
end