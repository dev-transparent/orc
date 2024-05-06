require "./src/orc"

# # Information could be pulled from the metastore
# file = File.open("./orc-file-11-format.orc") do |io|
#   Orc::File.new(io)
# end

# # Check if file is of any use to use by looking at types and column statistics
# # pp file.schema.field_names
# puts file.schema.fields.map(&.kind)
# # pp file.postscript
# # pp file.footer
# #

# # Now load the file properly to get the stripes / columns
# File.open("./orc-file-11-format.orc") do |io|
#   # We know which columns we want to read now and the file contains information about where the stripes start
#   reader = Orc::Reader.new(file, io)
#   reader.each_stripe do |stripe|
#     row_count = stripe.number_of_rows
#     streams_by_kind = stripe.streams.group_by(&.kind)

#     file.schema.fields.each do |field|
#       column = case field.kind
#       when Orc::Proto::Type::Kind::BOOLEAN
#         Orc::Columns::BooleanColumn.new(stripe, field)
#       when Orc::Proto::Type::Kind::INT
#         Orc::Columns::IntegerColumn.new(stripe, field)
#       when Orc::Proto::Type::Kind::BYTE
#         Orc::Columns::ByteColumn.new(stripe, field)
#       when Orc::Proto::Type::Kind::STRING
#         Orc::Columns::StringColumn.new(stripe, field)
#       when Orc::Proto::Type::Kind::FLOAT
#         Orc::Columns::FloatColumn.new(stripe, field)
#       when Orc::Proto::Type::Kind::DOUBLE
#         Orc::Columns::DoubleColumn.new(stripe, field)
#       else
#         next
#       end

#       results = column.to_a

#       puts "fetched #{field.kind}: #{results.size} of #{row_count}"
#       puts "examples: #{results.first(3)}"
#     end

#   end
# end
#

boolean_column = Orc::Writers::BooleanColumn.new(1)
integer_stream = Orc::Stream.new(Orc::Codecs::None.new, 2, Orc::Proto::Stream::Kind::DATA)
integer_writer = Orc::RunLengthIntegerWriter.new(integer_stream.buffer, true)

string_length_stream = Orc::Stream.new(Orc::Codecs::None.new, 3, Orc::Proto::Stream::Kind::LENGTH)
string_length_writer = Orc::RunLengthIntegerWriter.new(string_length_stream.buffer, false)

string_data_stream = Orc::Stream.new(Orc::Codecs::None.new, 3, Orc::Proto::Stream::Kind::DATA)
string_data_writer = Orc::RunLengthIntegerWriter.new(string_data_stream.buffer, false)

string_dictionary_stream = Orc::Stream.new(Orc::Codecs::None.new, 3, Orc::Proto::Stream::Kind::DICTIONARYDATA)

string_writer = Orc::StringDictionaryWriter.new(string_length_writer, string_data_writer, string_dictionary_stream.buffer)

words = ["hello", "goodbye", "how are you?", "good morning", "good night"]

100.times do |i|
  boolean_column.write(i % 2 == 0)
  integer_writer.write(i * -4)

  word = words[i % words.size]

  string_writer.write(word)
end

boolean_column.flush
integer_writer.flush
string_writer.flush

streams = boolean_column.streams + [integer_stream] + [string_length_stream, string_data_stream, string_dictionary_stream]

footer = Orc::Proto::StripeFooter.new(
  streams: streams.flat_map { |stream|
    Orc::Proto::Stream.new(kind: stream.kind, column: stream.column, length: stream.length)
  },
  columns: [
    Orc::Proto::ColumnEncoding.new(kind: Orc::Proto::ColumnEncoding::Kind::DIRECT),
    Orc::Proto::ColumnEncoding.new(kind: Orc::Proto::ColumnEncoding::Kind::DIRECT),
    Orc::Proto::ColumnEncoding.new(kind: Orc::Proto::ColumnEncoding::Kind::DIRECT),
    Orc::Proto::ColumnEncoding.new(kind: Orc::Proto::ColumnEncoding::Kind::DICTIONARY),
  ]
)

stripe = Orc::Stripe.new(
  streams: streams,
  footer: footer,
  number_of_rows: 100
)

schema = Orc::Schema.from_types(
  types: [
    Orc::Proto::Type.new(
      kind: Orc::Proto::Type::Kind::STRUCT,
      subtypes: [1u32, 2u32, 3u32],
      field_names: ["Boolean", "Integer", "String"]
    ),
    Orc::Proto::Type.new(
      kind: Orc::Proto::Type::Kind::BOOLEAN,
      subtypes: [] of UInt32,
      field_names: [] of String
    ),
    Orc::Proto::Type.new(
      kind: Orc::Proto::Type::Kind::INT,
      subtypes: [] of UInt32,
      field_names: [] of String
    ),
    Orc::Proto::Type.new(
      kind: Orc::Proto::Type::Kind::STRING,
      subtypes: [] of UInt32,
      field_names: [] of String
    )
  ]
)

File.open("./test-write.orc", "w") do |io|
  writer = Orc::Writer.new(io)
  writer.write_header
  writer.write_stripe(stripe)
  writer.write_footer(schema)
  writer.flush
  writer.close
end

# File.open("./test-write.orc") do |io|
#   bytes = io.getb_to_end

#   puts bytes.size
#   puts bytes.map(&.to_s(2, precision: 8))
# end

File.open("./test-write.orc") do |io|
  file = Orc::File.new(io)

  reader = Orc::Reader.new(file, io)
  reader.each_stripe do |stripe|
    row_count = stripe.number_of_rows

    streams_by_kind = stripe.streams.group_by(&.kind)

    file.schema.fields.each do |field|
      column = case field.kind
      when Orc::Proto::Type::Kind::BOOLEAN
        Orc::Columns::BooleanColumn.new(stripe, field)
      when Orc::Proto::Type::Kind::STRING
        Orc::Columns::StringColumn.new(stripe, field)
      else
        next
      end

      results = column.to_a

      puts "fetched #{field.kind}: #{results.size} of #{row_count}"
      puts "examples: #{results.first(100)}"
    end
  end
end