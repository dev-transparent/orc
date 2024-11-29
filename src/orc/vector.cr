require "./buffer"

module Orc
  abstract struct FieldVector
    def self.for_field(field : Field, capacity : Int32)
      case field.kind
      when .string?
        StringVector.new(capacity)
      when .struct?
        StructVector.for_field(field, capacity)
      else
        IntVector.new(capacity)
      end
    end
  end

  abstract struct PrimitiveVector(T) < FieldVector
    getter nulls : Array(Bool)
    getter values : Array(T?)

    def initialize(capacity : Int32)
      @nulls = Array(Bool).new(capacity, true)
      @values = Array(T?).new(capacity, nil)
    end
  end

  struct BooleanVector < PrimitiveVector(Bool)
  end

  struct IntVector < PrimitiveVector(Int64)
  end

  struct FloatVector < PrimitiveVector(Float64)
  end

  struct StringVector < PrimitiveVector(String)
  end

  struct BytesVector < PrimitiveVector(Bytes)
  end

  struct StructVector < FieldVector
    getter nulls : Array(Bool)
    getter values : Array(FieldVector)

    def initialize(@column_count : Int32, @capacity : Int32)
      @nulls = Array(Bool).new(@capacity, true)
      @values = Array(FieldVector).new(@column_count)
    end

    def self.for_field(field : Field, capacity : Int32)
      vector = StructVector.new(field.fields.size, capacity)

      field.fields.each_with_index do |field, index|
        vector.values << FieldVector.for_field(field, capacity)
      end

      vector
    end
  end
end