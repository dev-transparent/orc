module Orc
  class Field
    getter id : Int32
    getter kind : Orc::Proto::Type::Kind
    getter children : Array(Field)

    def initialize(@id : Int32, @kind : Orc::Proto::Type::Kind, @children : Array(Field) = [] of Field)
    end
  end

  class Schema
    getter root : Orc::Proto::Type
    getter types : Array(Orc::Proto::Type)
    getter fields : Array(Field)

    delegate field_names, to: root

    def initialize(@types : Array(Orc::Proto::Type))
      @root = types.first
      @fields = [] of Field

      root.subtypes.try &.each_with_index(1) do |subtype, id|
        type = @types[subtype]

        @fields << build_field(type, id)
      end
    end

    def self.from_types(types : Array(Orc::Proto::Type))
      new(types)
    end

    def build_field(type : Orc::Proto::Type, id : Int32) : Field
      subtypes = type.subtypes || [] of UInt32

      Field.new(
        id: id,
        kind: type.kind.not_nil!,
        children: subtypes.map { |subtype|
          build_field(types[subtype], id)
        }
      )
    end
  end
end