module Orc
    # Stripe (~250MB limit)
    #
    # 1. Indexes
    # 2. Data
    # 3. Footer
  class Stripe
    getter schema : Schema
    getter columns : Array(Column)
    getter rows : UInt64

    def initialize(@schema : Schema)
      @rows = 0u64
      @columns = [] of Column
    end

    def write(batch : WriteBatch)
      schema.fields.each_with_index do |field, column_index|
        column = columns[column_index] # Fields and columns should line up...
        vector = batch.columns[column_index]

        write_column(field, column, vector, batch.rows)
      end

      @rows += batch.rows
    end

    private def write_column(field : Field, column : Column, vector : FieldVector, rows : Int32)
      case field.kind
      when .int?
        int_vector = vector.as(IntVector)
        int_column = column.as(IntDirectColumn)

        rows.times do |row|
          if int_vector.nulls[row]
            int_column.append(nil)
          else
            int_column.append(int_vector.values[row].not_nil!)
          end
        end
      when .string?
        string_vector = vector.as(StringVector)
        string_column = column.as(StringDirectColumn)

        rows.times do |row|
          if string_vector.nulls[row]
            string_column.append(nil)
          else
            string_column.append(string_vector.values[row].not_nil!)
          end
        end
      when .struct?
        struct_vector = vector.as(StructVector)
        struct_column = column.as(StructDirectColumn)

        rows.times do |row|
          if struct_vector.nulls[row]
            struct_column.present.append(false)
          else
            struct_column.present.append(true)

            field.fields.each_with_index do |field, column_index|
              vector = struct_vector.values[column_index]
              column = struct_column.columns[column_index]

              write_column(field, column, vector, rows)
            end
          end
        end
      end
    end
  end
end