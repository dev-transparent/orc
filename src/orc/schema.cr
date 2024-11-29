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
        ),
        fields.map(&.to_protobuf)
      ].flatten
    end
  end

  struct Schema
    property fields : Array(Field)

    def initialize(@fields : Array(Field) = [] of Field)
    end

    def to_protobuf
      fields.flat_map(&.to_protobuf)
    end
  end
end