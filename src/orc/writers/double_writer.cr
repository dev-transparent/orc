require "./base"

module Orc
  module Writers
    class DoubleWriter < Base(Float64)
      def initialize(@io : IO)
        @minimum = nil
        @maximum = nil
        @sum = 0
      end

      def write(value : Float64)
        @io.write_bytes(value, IO::ByteFormat::LittleEndian)

        if @minimum.nil? || @minimum.not_nil! > value
          @minimum = value
        end

        if @maximum.nil? || @maximum.not_nil! < value
          @maximum = value
        end

        @sum += value.size
      end

      def statistics
        Orc::Proto::DoubleStatistics.new(
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