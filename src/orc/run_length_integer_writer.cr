module Orc
  class RunLengthIntegerWriter
    private property literals : StaticArray(Int64, 128)
    private property num_literals : Int32 = 0
    private property used : Int32 = 0
    private property repeat : Bool = false
    private property tail_run_length = 0
    private property delta = 0

    MIN_REPEAT_SIZE = 3
    MAX_REPEAT_SIZE = 127 + MIN_REPEAT_SIZE
    MIN_DELTA = -128
    MAX_DELTA = 127

    def initialize(@io : IO, @signed = false)
      @literals = uninitialized Int64[128]
    end

    def write(value : Int64)
      if @num_literals == 0
        @literals[@num_literals] = value
        @num_literals += 1
        @tail_run_length = 1
      elsif @repeat
        if value == @literals[0] + @delta * @num_literals
          @num_literals += 1

          flush if @num_literals == MAX_REPEAT_SIZE
        else
          flush
          @literals[@num_literals] = value
          @num_literals += 1
          @tail_run_length = 1
        end
      else
        if @tail_run_length == 1
          @delta = (value - @literals[@num_literals - 1]).to_i32

          if @delta < MIN_DELTA || @delta > MAX_DELTA
            @tail_run_length = 1
          else
            @tail_run_length = 2
          end
        elsif value == @literals[@num_literals - 1] + @delta.to_i64
          @tail_run_length += 1
        else
          @delta = (value - @literals[@num_literals - 1]).to_i32

          if @delta < MIN_DELTA || @delta > MAX_DELTA
            @tail_run_length = 1
          else
            @tail_run_length = 2
          end
        end

        if @tail_run_length == MIN_REPEAT_SIZE
          if @num_literals + 1 == MIN_REPEAT_SIZE
            @repeat = true
            @num_literals += 1
          else
            @num_literals -= MIN_REPEAT_SIZE - 1
            base = @literals[@num_literals]
            flush
            @literals[0] = base
            @repeat = true
            @num_literals = MIN_REPEAT_SIZE
          end
        else
          @literals[@num_literals] = value
          @num_literals += 1

          flush if @num_literals == 128
        end
      end
    end

    def flush
      return if @num_literals == 0

      if @repeat
        @io.write_byte((@num_literals - MIN_REPEAT_SIZE).to_u8)
        @io.write_byte(@delta.to_u8!)

        if @signed
          write_vs_long(@literals[0])
        else
          write_vu_long(@literals[0])
        end
      else
        @io.write_byte((-@num_literals).to_u8!)

        @num_literals.times do |i|
          if @signed
            write_vs_long(@literals[i])
          else
            write_vu_long(@literals[i])
          end
        end
      end

      @repeat = false
      @num_literals = 0
      @tail_run_length = 0
    end

    def close
      flush
    end

    def write_vs_long(value : Int64)
      write_vu_long((value << 1) ^ (value >> 63))
    end

    def write_vu_long(value : Int64)
      loop do
        if (value & ~0x7f) == 0
          @io.write_byte(value.to_u8)
          return
        end

        @io.write_byte((0x80 | (value & 0x7f)).to_u8)
        value = (value.to_i64 >> 7).to_u64
      end
    end
  end
end