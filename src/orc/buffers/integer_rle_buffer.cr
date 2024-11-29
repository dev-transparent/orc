module Orc
  struct IntegerRLEBuffer < Buffer(Int64)
    def initialize(@memory : IO::Memory, signed = false)
      super(@memory)

      # TODO: Refactor to avoid using a dedicated writer instance.. make this part of the buffer
      @writer = RunLengthIntegerWriter.new(@memory, signed)
    end

    def append(value : Int64)
      @writer.write(value)
      @size += 1
    end

    def flush
      @writer.flush
    end
  end
end