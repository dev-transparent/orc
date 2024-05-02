module Orc
  class FloatReader
    include Iterator(Float32)

    private getter stream : Stream

    def initialize(@stream : Stream)
    end

    def next
      stream.buffer.read_bytes(Float32, IO::ByteFormat::LittleEndian)
    rescue IO::EOFError
      stop
    end
  end
end