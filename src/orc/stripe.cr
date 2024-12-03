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

    def initialize(@schema : Schema, @rows : UInt64 = 0u64)
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

    def bytesize
      columns.sum(0) { |column| column.bytesize }
    end

    def self.from_reader(reader : Reader, information : Proto::StripeInformation)
      stripe_footer_offset = information.offset.not_nil! + information.data_length.not_nil! + information.index_length.not_nil!
      stripe_footer = reader.file.read_at(stripe_footer_offset, information.footer_length.not_nil!) do |io|
        Proto::StripeFooter.from_protobuf(io)
      end

      stream_offset = information.offset.not_nil!
      streams = stripe_footer.streams.not_nil!.compact_map do |stream|
        reader.file.read_at(stream_offset, stream.length.not_nil!) do |io|
          stream_offset += stream.length.not_nil!

          case stream.kind.not_nil!
          when Orc::Proto::Stream::Kind::DATA
            # TODO: Get the appropriate buffer for the type...from the schema
            DataStream.new(stream.column.not_nil!, BytesBuffer.new(io, stream.length.not_nil!))
          when Orc::Proto::Stream::Kind::LENGTH
            # LengthStream.new()
            next
          when Orc::Proto::Stream::Kind::DICTIONARYDATA
            next
          when Orc::Proto::Stream::Kind::PRESENT
            next
          when Orc::Proto::Stream::Kind::ROWINDEX
            next
          end
        end
      end

      streams_by_columns = streams.group_by(&.column)

      # Generate each column for the schema and pull in the relevant fields

      stripe = Stripe.new(reader.schema, information.number_of_rows.not_nil!)
      stripe
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