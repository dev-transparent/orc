module Orc
  class Stream
    getter buffer : IO::Memory
    getter codec : Codec
    getter column : UInt32
    getter kind : Orc::Proto::Stream::Kind

    delegate rewind, to: buffer

    def initialize(@codec : Codec, @column : UInt32, @kind : Orc::Proto::Stream::Kind, length : Int = 64)
      @buffer = IO::Memory.new(length)
    end

    def length
      buffer.size.to_u64
    end

    def self.from_reader(reader : Reader, column : UInt32, kind : Orc::Proto::Stream::Kind, length : UInt64)
      new(reader.codec, column, kind, length).tap do |stream|
        IO.copy(reader.io, stream.buffer, length)
        stream.rewind
      end
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