require "./base"

module Orc
  module Writers
    class BooleanWriter < Base(Bool)
      def initialize(@writer : RunLengthBooleanWriter)
        @count = [0u64, 0u64]
      end

      def write(value : Bool)
        @count[value ? 1 : 0] += 1
        @writer.write(value)
      end

      def statistics
        Orc::Proto::BucketStatistics.new(count: @count)
      end

      def flush
        @writer.flush
      end
    end
  end
end