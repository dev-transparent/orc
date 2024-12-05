module Orc
  class StringDirectColumn < Column
    property data : DataStream(BytesBuffer)
    property length : LengthStream
    property present : PresentStream?

    property size : UInt64

    def initialize(@id : UInt32)
      super

      @size = 0u64
      @data = DataStream(BytesBuffer).new(@id)
      @length = LengthStream.new(@id)
      @present = PresentStream.new(@id)
    end

    def initialize(@id : UInt32, @size : UInt64, @data : DataStream(BytesBuffer), @length : LengthStream, @present : PresentStream? = nil)
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
      StringDirectColumnIterator.new(self)
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

    private class StringDirectColumnIterator
      include Iterator(String?)

      @present_iterator : Iterator(Bool)?
      @length_iterator : Iterator(Int64)

      def initialize(@column : StringDirectColumn)
        @present_iterator = @column.present.try &.values.each
        @length_iterator = @column.length.values.each

        @data_memory = @column.data.buffer.memory.to_slice
        @data_offset = 0

        @row = 0
      end

      def next
        if @row >= @column.size
          return stop
        end

        is_present = if iterator = @present_iterator
          iterator.next
        else
          true
        end

        if is_present.is_a?(Iterator::Stop)
          return stop
        end

        if !is_present
          return nil
        end

        length = @length_iterator.next

        if length.is_a?(Iterator::Stop)
          return stop
        end

        String.new(@data_memory[@data_offset, length]).tap do
          @data_offset += length
          @row += 1
        end
      end
    end
  end
end