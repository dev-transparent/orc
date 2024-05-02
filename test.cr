require "./src/orc"

# Information could be pulled from the metastore
file = File.open("./orc-file-11-format.orc") do |io|
  Orc::File.new(io)
end

# Check if file is of any use to use by looking at types and column statistics
# pp file.schema.field_names
puts file.schema.fields.map(&.kind)
# pp file.postscript
# pp file.footer
#

# Now load the file properly to get the stripes / columns
File.open("./orc-file-11-format.orc") do |io|
  # We know which columns we want to read now and the file contains information about where the stripes start
  reader = Orc::Reader.new(file, io)
  reader.each_stripe do |stripe|
    row_count = stripe.info.number_of_rows.not_nil!
    streams_by_kind = stripe.streams.group_by(&.kind)

    file.schema.fields.each do |field|
      encoding = stripe.column_encodings[field.id]
      data_stream = streams_by_kind[Orc::Proto::Stream::Kind::DATA].find { |stream| stream.column == field.id }
      present_stream = streams_by_kind[Orc::Proto::Stream::Kind::PRESENT]?.try &.find { |stream| stream.column == field.id }

      unless data_stream
        puts "Could not find data stream for #{field.kind} #{field.id}"
        next
      end

      column = case field.kind
      when Orc::Proto::Type::Kind::BOOLEAN
        Orc::Columns::BooleanColumn.new(stripe, field)
      when Orc::Proto::Type::Kind::INT
        Orc::Columns::IntegerColumn.new(stripe, field)
      when Orc::Proto::Type::Kind::BYTE
        Orc::Columns::ByteColumn.new(stripe, field)
      when Orc::Proto::Type::Kind::STRING
        length_stream = streams_by_kind[Orc::Proto::Stream::Kind::LENGTH].find! { |stream| stream.column == field.id }

        Orc::Columns::StringColumn.new(stripe, field)
      else
        next
      end

      results = column.first(row_count).to_a

      puts "fetched #{field.kind}: #{results.size} of #{row_count}"
      puts "examples: #{results.first(3)}"
    end

  end
end