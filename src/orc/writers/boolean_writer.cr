require "./base"

module Orc
  module Writers
    class BooleanWriter < Base(Bool)
      def initialize(@writer : RunLengthBooleanWriter)
      end

      def write(value : Bool)
        @writer.write(value)
      end

      def flush
        @writer.flush
      end
    end
  end
end