require "./base"

module Orc
  module Writers
    class IntegerWriter < Base(Int64)
      def initialize(@writer : RunLengthIntegerWriter)
        @minimum = nil
        @maximum = nil
        @sum = 0
      end

      def write(value : Int64)
        @writer.write(value)

        if @minimum.nil? || @minimum.not_nil! > value
          @minimum = value
        end

        if @maximum.nil? || @maximum.not_nil! < value
          @maximum = value
        end

        @sum += value
      end

      def statistics
        Orc::Proto::IntegerStatistics.new(
          minimum: @minimum,
          maximum: @maximum,
          sum: @sum
        )
      end

      def flush
        @writer.flush
      end
    end
  end
end