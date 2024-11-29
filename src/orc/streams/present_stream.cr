module Orc
  class PresentStream < Stream
    def initialize(@buffer : BooleanRLEBuffer = BooleanRLEBuffer.new(IO::Memory.new))
    end

    def kind
      Proto::Stream::Kind::PRESENT
    end

    def append(value : Bool)
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