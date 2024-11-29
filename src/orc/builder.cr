module Orc
  class Builder
    private getter schema : Schema

    def initialize(@schema : Schema)
    end

    def build_stripe
      stripe = Stripe.new(schema)

      schema.fields.each do |field|
        stripe.columns << build_column_for_field(field)
      end

      stripe
    end

    private def build_column_for_field(field)
      case field.kind
      when .struct?
        StructDirectColumn.new(field.id).tap do |column|
          field.fields.each do |field|
            column.columns << build_column_for_field(field)
          end
        end
      else
        field_to_column_class(field).new(field.id)
      end
    end

    private def field_to_column_class(field) : Column.class
      case field.kind
      when Proto::Type::Kind::STRING
        StringDirectColumn
      when Proto::Type::Kind::INT
        IntDirectColumn
      when Proto::Type::Kind::BOOLEAN
        BooleanDirectColumn
      when Proto::Type::Kind::DOUBLE
        DoubleDirectColumn
      when Proto::Type::Kind::TIMESTAMP
        TimestampDirectColumn
      when Proto::Type::Kind::BINARY
        BinaryDirectColumn
      when Proto::Type::Kind::STRUCT
        StructDirectColumn
      else
        raise "Unsupported type #{field.kind}"
      end
    end
  end
end