require "./base"

module Orc
  module Writers
    class StringWriter < Base(String)
      def initialize(@writer : StringDictionaryWriter | StringDirectWriter)
        @minimum = nil
        @maximum = nil
        @sum = 0
      end

      def write(value : String)
        @writer.write(value)

        if @minimum.nil? || @minimum.not_nil! > value
          @minimum = value
        end

        if @maximum.nil? || @maximum.not_nil! < value
          @maximum = value
        end

        @sum += value.size
      end

      def statistics
        Orc::Proto::StringStatistics.new(
          minimum: @minimum,
          maximum: @maximum,
          sum: @sum,
        )
      end

      def flush
        @writer.flush
      end
    end
  end
end