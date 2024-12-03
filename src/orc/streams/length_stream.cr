module Orc
  class LengthStream < Stream
    getter column : UInt32

    def initialize(@column : UInt32, @buffer : IntegerRLEBuffer = IntegerRLEBuffer.new(IO::Memory.new, false))
    end

    def kind
      Proto::Stream::Kind::LENGTH
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