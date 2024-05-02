module Orc
  # alias ColumnType = BooleanColumn | StringColumn

  # class Batch
  #   getter columns : Array(ColumnType) = [] of ColumnType

  #   def initialize(@schema : Schema, size : Int32)
  #     @schema.fields.each do |field|
  #       case field.type
  #       when Types::BooleanType.class
  #         @columns << BooleanColumn.new(size)
  #       when Types::StringType.class
  #         @columns << StringColumn.new(size)
  #       else
  #         raise "Unsupported column type #{field.type.class}"
  #       end
  #     end
  #   end
  # end

  # abstract class Column(T)
  #   getter vector : Array(T | Nil)

  #   def initialize(size : Int32)
  #     @vector = Array(T | Nil).new(size, nil)
  #   end
  # end

  # class BooleanColumn < Column(Bool)
  # end

  # class StringColumn < Column(Bool)
  # end
end