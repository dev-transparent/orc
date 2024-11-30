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

  struct BooleanVector < FieldVector
    getter nulls : Array(Bool)
    getter values : Array(Bool?)

    def initialize(capacity : Int32)
      @nulls = Array(Bool).new(capacity, true)
      @values = Array(Bool?).new(capacity, nil)
    end
  end

  struct IntVector < FieldVector
    getter nulls : Array(Bool)
    getter values : Array(Int64?)

    def initialize(capacity : Int32)
      @nulls = Array(Bool).new(capacity, true)
      @values = Array(Int64?).new(capacity, nil)
    end
  end

  struct FloatVector < FieldVector
    getter nulls : Array(Bool)
    getter values : Array(Float64??)

    def initialize(capacity : Int32)
      @nulls = Array(Bool).new(capacity, true)
      @values = Array(Float64?).new(capacity, nil)
    end
  end

  struct StringVector < FieldVector
    getter nulls : Array(Bool)
    getter values : Array(String?)

    def initialize(capacity : Int32)
      @nulls = Array(Bool).new(capacity, true)
      @values = Array(String?).new(capacity, nil)
    end
  end

  struct BytesVector < FieldVector
    getter nulls : Array(Bool)
    getter values : Array(Bytes?)

    def initialize(capacity : Int32)
      @nulls = Array(Bool).new(capacity, true)
      @values = Array(Bytes?).new(capacity, nil)
    end
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