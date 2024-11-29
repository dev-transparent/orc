module Orc
  class WriteBatch
    DEFAULT_CAPACITY = 10_000

    property rows : Int32
    getter columns : Array(FieldVector)

    def initialize(@column_count : Int32, @capacity : Int32 = DEFAULT_CAPACITY)
      @rows = 0
      @columns = Array(FieldVector).new(@column_count)
    end

    def reset
      @columns.each(&.reset)
    end

    def self.for_schema(schema : Schema, capacity : Int32 = DEFAULT_CAPACITY)
      batch = WriteBatch.new(schema.fields.size, capacity)

      schema.fields.each_with_index do |field, index|
        batch.columns << FieldVector.for_field(field, capacity)
      end

      batch
    end
  end
end