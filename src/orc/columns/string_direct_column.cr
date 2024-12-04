module Orc
  class StringDirectColumn < Column
    property data : DataStream(BytesBuffer)
    property length : LengthStream
    property present : PresentStream?

    property size : Int32

    def initialize(@id : UInt32)
      super

      @size = 0
      @data = DataStream(BytesBuffer).new(@id)
      @length = LengthStream.new(@id)
      @present = PresentStream.new(@id)
    end

    def initialize(@id : UInt32, @size : Int32, @data : DataStream(BytesBuffer), @length : LengthStream, @present : PresentStream? = nil)
    end

    def encoding : Proto::ColumnEncoding
      Proto::ColumnEncoding.new(kind: Proto::ColumnEncoding::Kind::DIRECT)
    end

    def append(value : String?)
      if value
        bytes = value.to_slice

        data.append(bytes)
        length.append(bytes.size)
        present.try &.append(true)
      else
        present.try &.append(false)
      end

      @size += 1
    end

    def each
      ColumnIterator(String?).new(self)
    end

    def to_io(io)
      streams.each do |stream|
        stream.to_io(io)
      end
    end

    def bytesize
      data.bytesize + present.bytesize + length.bytesize
    end

    def streams
      {data, present, length}
    end

    class ColumnIterator(T)
      include Iterator(T)

      def initialize(@column : StringDirectColumn)
      end

      def next
        stop
      end
    end
  end
end