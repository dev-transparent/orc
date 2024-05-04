module Orc
  class Stream
    getter buffer : IO::Memory
    getter codec : Codec
    getter column : UInt32
    getter kind : Orc::Proto::Stream::Kind
    getter length : UInt64

    delegate rewind, to: buffer

    def initialize(@buffer : IO::Memory, @codec : Codec, @column : UInt32, @kind : Orc::Proto::Stream::Kind, @length : UInt64)
    end

    def self.from_reader(reader : Reader, column : UInt32, kind : Orc::Proto::Stream::Kind, length : UInt64)
      buffer = IO::Memory.new(length)
      IO.copy(reader.io, buffer, length)
      buffer.rewind

      new(buffer, reader.codec, column, kind, length)
    end

    def data?
      kind.in?([
        Orc::Proto::Stream::Kind::PRESENT,
        Orc::Proto::Stream::Kind::DATA,
        Orc::Proto::Stream::Kind::LENGTH,
        Orc::Proto::Stream::Kind::DICTIONARYDATA,
        Orc::Proto::Stream::Kind::ENCRYPTEDDATA,
      ])
    end

    def index?
      kind.in?([
        Orc::Proto::Stream::Kind::ROWINDEX,
        Orc::Proto::Stream::Kind::BLOOMFILTER,
        Orc::Proto::Stream::Kind::BLOOMFILTERUTF8,
        Orc::Proto::Stream::Kind::ENCRYPTEDINDEX,
      ])
    end

    def to_io(io)
      buffer.rewind
      IO.copy(buffer, io, length)
    end
  end
end