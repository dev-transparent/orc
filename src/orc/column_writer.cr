module Orc
  class ColumnWriter(T)
    getter rows : Int32 = 0
    getter number_of_values = 0
    getter? has_missing = false

    def initialize(@writer : Writers::Base(T), @presence : RunLengthBooleanWriter)
    end

    def write(value : T?)
      if !value.nil?
        @writer.write(value)

        # If there are missing values we need to record in present stream
        @presence.write(true) if has_missing?

        @number_of_values += 1
      else
        # We might need to backfill in present rows
        unless has_missing?
          rows.times do
            @presence.write(true)
          end

          @has_missing = true
        end

        # Record that this value was not present
        @presence.write(false)
      end

      @rows += 1
    end

    def statistics
      statistics = Orc::Proto::ColumnStatistics.new(number_of_values: number_of_values, has_null: has_missing?)

      case @writer
      when Writers::BooleanWriter
        statistics.bucket_statistics = @writer.statistics
      when Writers::DoubleWriter, Writers::FloatWriter
        statistics.double_statistics = @writer.statistics
      when Writers::IntegerWriter
        statistics.int_statistics = @writer.statistics
      when Writers::StringWriter
        statistics.string_statistics = @writer.statistics
      end

      statistics
    end

    def flush
      @writer.flush
      @presence.flush
    end
  end
end