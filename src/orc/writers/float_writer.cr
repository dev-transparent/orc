require "./base"

module Orc
  module Writers
    class FloatWriter < Base(Float32)
      def initialize(@io : IO)
        @minimum = nil
        @maximum = nil
        @sum = 0
      end

      def write(value : Float32)
        @io.write_bytes(value, IO::ByteFormat::LittleEndian)

        if @minimum.nil? || @minimum.not_nil! > value
          @minimum = value
        end

        if @maximum.nil? || @maximum.not_nil! < value
          @maximum = value
        end

        @sum += value
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