module Orc
  struct BooleanRLEBuffer < Buffer(Bool)
    def initialize(@memory : IO::Memory)
      super(@memory)

      # TODO: Refactor to avoid using a dedicated writer instance.. make this part of the buffer
      @writer = RunLengthBooleanWriter.new(@memory)
    end

    def append(value : Bool)
      @writer.write(value)
    end

    def values
      RunLengthBooleanReader.new(@memory).to_a
    end

    def flush
      @writer.flush
    end
  end
end