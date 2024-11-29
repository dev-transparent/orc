module Orc
  abstract struct Buffer(T)
    getter memory : IO::Memory
    getter size : Int32

    def initialize(@memory : IO::Memory)
      @size = 0
    end

    def initialize(@memory : IO::Memory, @size : Int32)
    end

    def to_io(io)
      memory.rewind
      IO.copy(memory, io)
    end

    def bytesize
      @memory.size
    end

    abstract def append(value : T)
    abstract def flush
  end
end

require "./buffers/**"