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
      streams_by_column_and_kind = {} of Tuple(UInt32, Proto::Stream::Kind) => IO::Memory

      # Allocate buffers for each stream
      stripe_footer.streams.not_nil!.each do |stream|
        reader.file.read_at(stream_offset, stream.length.not_nil!) do |io|
          stream_offset += stream.length.not_nil!

          streams_by_column_and_kind[{ stream.column.not_nil!, stream.kind.not_nil! }] = IO::Memory.new(io.getb_to_end)
        end
      end

      # Generate each column for the schema and pull in the relevant fields
      stripe = Stripe.new(reader.schema, information.number_of_rows.not_nil!)

      reader.schema.fields.each do |field|
        encoding = stripe_footer.columns.not_nil![field.id]

        case field.kind
        when .boolean?
          data_buffer = streams_by_column_and_kind[{ field.id, Proto::Stream::Kind::DATA }]
          data = DataStream(BooleanRLEBuffer).new(field.id, BooleanRLEBuffer.new(data_buffer))

          present_buffer = streams_by_column_and_kind[{ field.id, Proto::Stream::Kind::PRESENT }]?
          present = if present_buffer
            PresentStream.new(field.id, BooleanRLEBuffer.new(present_buffer))
          end

          stripe.columns << BooleanDirectColumn.new(
            id: field.id,
            size: 0, # TODO: Find the size of the column?
            data: data,
            present: present,
          )
        when .string?
          case encoding.kind.not_nil!
          when .direct?
            data_buffer = streams_by_column_and_kind[{ field.id, Proto::Stream::Kind::DATA }]
            data = DataStream(BytesBuffer).new(field.id, BytesBuffer.new(data_buffer))

            length_buffer = streams_by_column_and_kind[{ field.id, Proto::Stream::Kind::LENGTH }]
            length = LengthStream.new(field.id, IntegerRLEBuffer.new(length_buffer, false))

            present_buffer = streams_by_column_and_kind[{ field.id, Proto::Stream::Kind::PRESENT }]?
            present = if present_buffer
              PresentStream.new(field.id, BooleanRLEBuffer.new(present_buffer))
            end

            stripe.columns << StringDirectColumn.new(
              id: field.id,
              size: 0, # TODO: Find the size of the column?
              data: data,
              length: length,
              present: present,
            )
          end
        end
      end

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