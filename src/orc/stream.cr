module Orc
  class Stream
    getter buffer : IO::Memory
    getter codec : Codec
    getter column : UInt32
    getter kind : Orc::Proto::Stream::Kind

    delegate rewind, to: buffer

    def initialize(@buffer : IO::Memory, @codec : Codec, @column : UInt32, @kind : Orc::Proto::Stream::Kind)
    end

    def self.from_reader(reader : Reader, column : UInt32, kind : Orc::Proto::Stream::Kind, length : UInt64)
      buffer = IO::Memory.new(length)
      IO.copy(reader.io, buffer, length)
      buffer.rewind

      new(buffer, reader.codec, column, kind)
    end
  end
end
