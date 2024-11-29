module Orc
  class StructDirectColumn < Column
    property columns : Array(Column)
    property present : PresentStream
    property size : Int32

    def initialize(@id : UInt32)
      super

      @size = 0
      @present = PresentStream.new
      @columns = [] of Column
    end

    def encoding : Proto::ColumnEncoding
      Proto::ColumnEncoding.new(kind: Proto::ColumnEncoding::Kind::DIRECT)
    end

    def to_io(io)
      present.to_io(io)

      columns.each do |column|
        column.to_io(io)
      end
    end

    def bytesize
      present.bytesize
    end

    def streams : Tuple(Stream)
      {present}
    end
  end
end