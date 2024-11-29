module Orc
  class BooleanDirectColumn < Column
    property data : DataStream(BooleanRLEBuffer)
    property present : PresentStream
    property size : Int32

    def initialize(@id : UInt32)
      super

      @size = 0
      @data = DataStream(BooleanRLEBuffer).new
      @present = PresentStream.new
    end

    def encoding : Proto::ColumnEncoding
      Proto::ColumnEncoding.new(kind: Proto::ColumnEncoding::Kind::DIRECT)
    end

    def append(value : Bool?)
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