module Orc
  struct BooleanRLEBuffer < Buffer(Bool)
    def initialize(@memory : IO::Memory)
      super(@memory)

      # TODO: Refactor to avoid using a dedicated writer instance.. make this part of the buffer
      @writer = RunLengthBooleanWriter.new(@memory)
    end

    def append(value : Bool)
      @writer.write(value)
      @size += 1
    end

    def flush
      @writer.flush
    end
  end
end