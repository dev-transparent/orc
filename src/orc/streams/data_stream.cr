module Orc
  class DataStream(B) < Stream
    BUFFER_SIZE = 64 * 1024

    def initialize(@buffer : B = B.new(IO::Memory.new(BUFFER_SIZE)))
    end

    def kind
      Proto::Stream::Kind::DATA
    end

    def append(value)
      @buffer.append(value)
    end

    def bytesize
      @buffer.bytesize
    end

    def flush
      @buffer.flush
    end

    def to_io(io)
      @buffer.to_io(io)
    end
  end
end