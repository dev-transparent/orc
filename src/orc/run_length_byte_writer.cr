module Orc
  class RunLengthByteWriter
    MIN_REPEAT_SIZE = 3
    MAX_LITERAL_SIZE = 128

    private property literals : StaticArray(UInt8, 128)
    private property num_literals = 0
    private property repeat = false
    private property tail_run_length = 0

    def initialize(@io : IO)
      @literals = uninitialized UInt8[128]
    end

    def write(byte : UInt8)
      # If we haven't seen a value yet we don't know whether it is a run or not so just record
      if @num_literals == 0
        @literals[@num_literals] = byte
        @num_literals += 1
        @tail_run_length = 1
      elsif @repeat
        # If we are in a run then check the value matches the previous, if so we just increment the number of values in the run. Otherwise we need to write the values and start a new run
        if @literals[0]? == byte
          @num_literals += 1
          flush if @num_literals == MAX_LITERAL_SIZE
        else
          flush

          @literals[@num_literals] = byte
          @num_literals += 1
          @tail_run_length = 1
        end
      else
        # If the value is the same as the previous recorded we might be in a repeating sequence so increase the count
        if @literals[@num_literals - 1]? == byte
          @tail_run_length += 1
        else
          @tail_run_length = 1
        end

        if @tail_run_length == MIN_REPEAT_SIZE
          # Check if recording this value will put us at the minimum length for a run
          if @num_literals + 1 == MIN_REPEAT_SIZE
            @repeat = true
            @num_literals += 1
          else
            @num_literals -= MIN_REPEAT_SIZE - 1
            flush
            @literals[0] = byte
            @repeat = true
            @num_literals = MIN_REPEAT_SIZE
          end
        else
          @literals[@num_literals] = byte
          @num_literals += 1

          flush if @num_literals == MAX_LITERAL_SIZE
        end
      end
    end

    def flush
      return unless @num_literals > 0

      if @repeat
        @io.write_byte((@num_literals - MIN_REPEAT_SIZE).to_u8)
        @io.write_byte(@literals[0])
      else
        @io.write_byte((-@num_literals).to_u8!)

        # TODO: Optimize by writing all bytes at the same time?
        @num_literals.times do |i|
          @io.write_byte(@literals[i])
        end
      end

      @repeat = false
      @tail_run_length = 0
      @num_literals = 0
    end

    def close
      flush
    end
  end
end