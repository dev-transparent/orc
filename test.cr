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

streams = [] of Orc::Stream

stripe = Orc::Stripe.new(
  streams: streams,
  footer: Orc::Proto::StripeFooter.new(
    streams: streams.map { |stream|
      Orc::Proto::Stream.new(kind: stream.kind, column: stream.column, length: stream.length)
    },
    columns: [] of Orc::Proto::ColumnEncoding
  ),
  number_of_rows: 0
)

File.open("./test-write.orc", "w") do |io|
  Orc::Writer.new(io) do |writer|
    writer.write_stripe(stripe)
  end
end

File.open("./test-write.orc") do |io|
  pp Orc::File.new(io)
end