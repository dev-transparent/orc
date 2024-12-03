module Orc
  abstract class Column
    getter id : UInt32

    def initialize(@id : UInt32)
    end

    abstract def encoding : Proto::ColumnEncoding
    abstract def streams
    abstract def bytesize
    abstract def to_io(io)
  end
end

require "./columns/**"