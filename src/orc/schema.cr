module Orc
  struct Field
    property id : UInt32
    property name : String
    property kind : Proto::Type::Kind
    property fields : Array(Field)

    def initialize(@id, @name, @kind, @fields = [] of Field)
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
    private property id : UInt32
    property fields : Array(Field)

    def initialize(@fields : Array(Field) = [] of Field)
      @id = 1
    end

    def next_id : UInt32
      id.tap do
        @id += 1
      end
    end

    def self.from_footer(footer : Proto::Footer)
      schema = Schema.new
      types = footer.types.not_nil!

      root = types.first
      root.subtypes.not_nil!.each_with_index do |subtype, index|
        schema.fields << Orc::Field.new(
          id: subtype.not_nil!,
          name: root.field_names.not_nil![index],
          kind: types[subtype.not_nil!].kind.not_nil!,
        )

        # TODO: Extract fields for subtypes...
      end

      schema
    end

    def self.fields_for_type(type)
      Orc::Field.new()
      type.subtypes.not_nil!.each do |subtype|

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