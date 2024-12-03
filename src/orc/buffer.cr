module Orc
  abstract struct Buffer(T)
    getter memory : IO
    getter size : UInt64

    def initialize(@memory : IO)
      @size = 0u64
    end

    def initialize(@memory : IO, @size : UInt64)
    end

    def to_io(io)
      memory.rewind
      IO.copy(memory, io)
    end

    def bytesize
      @size
    end

    abstract def append(value : T)
    abstract def flush
  end
end

require "./buffers/**"