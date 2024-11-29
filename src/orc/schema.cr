module Orc
  struct Field
    property id : UInt32
    property name : String
    property kind : Proto::Type::Kind
    property encoding : Proto::ColumnEncoding
    property fields : Array(Field)

    def initialize(@id, @name, @kind, @encoding, @fields = [] of Field)
    end

    def all_fields
      fields.flat_map(&.all_fields)
    end

    def to_protobuf : Array(Proto::Type)
      [
        Proto::Type.new(
          kind: kind,
          subtypes: fields.map(&.id),
          field_names: fields.map(&.name)
        )
      ] + fields.flat_map(&.to_protobuf)
    end
  end

  struct Schema
    property id : UInt32 = 1
    property fields : Array(Field)

    def initialize(@fields : Array(Field) = [] of Field)
    end

    def next_id : UInt32
      id.tap do
        id += 1
      end
    end

    def to_protobuf
      [
        Proto::Type.new(
          kind: Proto::Type::Kind::STRUCT,
          subtypes: fields.map(&.id),
          field_names: fields.map(&.name)
        )
      ] + fields.flat_map(&.to_protobuf)
    end
  end
end