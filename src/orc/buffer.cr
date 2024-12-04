module Orc
  abstract struct Buffer(T)
    getter memory : IO::Memory

    def initialize(@memory : IO::Memory)
    end

    def to_io(io)
      memory.rewind
      IO.copy(memory, io)
    end

    def bytesize
      memory.size
    end

    abstract def append(value : T)
    abstract def flush
  end
end

require "./buffers/**"