require "./base"

module Orc
  module Writers
    class ByteWriter < Base(UInt8)
      def initialize(@writer : RunLengthByteWriter)
      end

      def write(value : UInt8)
        @writer.write(value)
      end

      def flush
        @writer.flush
      end
    end
  end
end