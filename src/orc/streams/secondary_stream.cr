module Orc
  class SecondaryStream(B) < Stream
    getter buffer : B
    getter column : UInt32

    def initialize(@column : UInt32, @buffer : B = B.new(IO::Memory.new))
    end

    def kind
      Proto::Stream::Kind::SECONDARY
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