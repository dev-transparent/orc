module Orc
  struct IntegerRLEBuffer < Buffer(Int64)
    def initialize(@memory : IO::Memory, @signed = false)
      super(@memory)

      # TODO: Refactor to avoid using a dedicated writer instance.. make this part of the buffer
      @writer = RunLengthIntegerWriter.new(@memory, @signed)
    end

    def append(value : Int64)
      @writer.write(value)
    end

    def values
      RunLengthIntegerReader.new(@memory, @signed).to_a
    end

    def flush
      @writer.flush
    end
  end
end