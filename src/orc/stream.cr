module Orc
  class Stream
    property reader : Reader
    property column : UInt32
    property length : UInt64
    property kind : Orc::Proto::Stream::Kind

    getter buffer : IO::Memory

    delegate codec, io, to: reader

    def initialize(@reader : Reader, @column : UInt32, @length : UInt64, @kind : Orc::Proto::Stream::Kind)
      @buffer = IO::Memory.new(length)
      IO.copy(io, buffer, length)
      @buffer.rewind
    end
  end
end
