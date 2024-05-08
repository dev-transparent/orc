module Orc
  class ColumnWriter(T)
    getter rows : Int32 = 0
    getter? has_missing = false

    def initialize(@writer : Writers::Base(T), @presence : RunLengthBooleanWriter)
    end

    def write(value : T?)
      if !value.nil?
        @writer.write(value)

        # If there are missing values we need to record in present stream
        @presence.write(true) if has_missing?
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

    def flush
      @writer.flush
      @presence.flush
    end
  end
end