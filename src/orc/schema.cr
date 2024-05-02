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

      root.subtypes.try &.each do |subtype|
        type = @types[subtype]

        @fields << build_field(type)
      end
    end

    def build_field(type : Orc::Proto::Type) : Field
      id = @types.index(type).not_nil!
      subtypes = type.subtypes || [] of UInt32

      Field.new(
        id: id,
        kind: type.kind.not_nil!,
        children: subtypes.map { |subtype|
          build_field(types[subtype])
        }
      )
    end
  end
end