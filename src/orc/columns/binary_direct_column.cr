module Orc
  class BinaryDirectColumn < Column
    property data : DataStream(BytesBuffer)
    property length : LengthStream
    property present : PresentStream
    property size : UInt64

    def initialize(@id : UInt32)
      super

      @size = 0u64
      @data = DataStream(BytesBuffer).new(@id)
      @length = LengthStream.new(@id)
      @present = PresentStream.new(@id)
    end

    def encoding : Proto::ColumnEncoding
      Proto::ColumnEncoding.new(kind: Proto::ColumnEncoding::Kind::DIRECT)
    end

    def append(value : Bytes?)
      if value
        data.append(value)
        length.append(value.size)
        present.append(true)
      else
        present.append(false)
      end

      @size += 1
    end

    def each
      ColumnIterator(Bytes?).new(self)
    end

    def bytesize
      data.bytesize + present.bytesize + length.bytesize
    end

    def to_io(io)
      streams.each do |stream|
        stream.to_io(io)
      end
    end

    def streams
      {data, length, present}
    end
  end
end