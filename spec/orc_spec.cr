require "./spec_helper"

describe Orc do
  it "creates and reads orc files" do
    schema = Orc::Schema.new
    schema.fields << Orc::Field.new(
      id: schema.next_id,
      name: "span_id",
      kind: Orc::Proto::Type::Kind::STRING,
    )

    write_batch = Orc::WriteBatch.for_schema(schema)
    write_batch.columns[0].as(Orc::StringVector).nulls[0] = false
    write_batch.columns[0].as(Orc::StringVector).values[0] = "some value"
    write_batch.columns[0].as(Orc::StringVector).nulls[1] = false
    write_batch.columns[0].as(Orc::StringVector).values[1] = "another"
    write_batch.columns[0].as(Orc::StringVector).nulls[2] = false
    write_batch.columns[0].as(Orc::StringVector).values[2] = "random value"
    write_batch.rows = 3

    builder = Orc::Builder.new(schema)

    stripe = builder.build_stripe
    stripe.write(write_batch)

    File.open("./tmp/test.orc", "wb") do |io|
      writer = Orc::Writer.new(io, schema)
      writer.write_stripe(stripe)
      writer.write_footer
    end

    # Read in the file and splat into stripes

    File.open("./tmp/test.orc", "rb") do |io|
      reader = Orc::Reader.new(io)
      reader.each_stripe.each do |stripe|
        pp stripe
      end
    end
  end
end
