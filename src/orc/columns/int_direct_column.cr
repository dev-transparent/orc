module Orc
  class IntDirectColumn < Column
    property data : DataStream(IntegerRLEBuffer)
    property present : PresentStream
    property size : Int32

    def initialize(@id : UInt32)
      super

      @size = 0
      @data = DataStream.new(IntegerRLEBuffer.new(IO::Memory.new, signed: true))
      @present = PresentStream.new
    end

    def encoding : Proto::ColumnEncoding
      Proto::ColumnEncoding.new(kind: Proto::ColumnEncoding::Kind::DIRECT)
    end

    def append(value : Int64?)
      if value
        data.append(value)
        present.append(true)
      else
        present.append(false)
      end

      @size += 1
    end

    def to_io(io)
      streams.each do |stream|
        stream.to_io(io)
      end
    end

    def bytesize
      data.bytesize + present.bytesize
    end

    def streams
      {data, present}
    end
  end
end