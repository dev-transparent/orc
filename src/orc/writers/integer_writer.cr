require "./base"

module Orc
  module Writers
    class IntegerWriter < Base(Int64)
      def initialize(@writer : RunLengthIntegerWriter)
      end

      def write(value : Int64)
        @writer.write(value)
      end

      def flush
        @writer.flush
      end
    end
  end
end