require "../spec_helper"

describe Orc::WriteBatch do
  it "creates batch from schema" do
    schema = Orc::Schema.new(fields: [
      Orc::Field.new(
        id: 1,
        name: "string",
        kind: Orc::Proto::Type::Kind::STRING,
        encoding: Orc::Proto::ColumnEncoding.new(kind: Orc::Proto::ColumnEncodin::Kind::DIRECT)
      ),
      Orc::Field.new(
        id: 1,
        name: "int",
        kind: Orc::Proto::Type::Kind::INT,
        encoding: Orc::Proto::ColumnEncoding.new(kind: Orc::Proto::ColumnEncodin::Kind::DIRECT)
      )
    ])

    batch = Orc::WriteBatch.for_schema(schema, 5)
    batch.columns[0].nulls[0] = false
    batch.columns[0].values[0] = "test"
    batch.columns[1].nulls[0] = false
    batch.columns[1].values[0] = 5

    batch.columns[0].nulls.should eq([false, true, true, true, true])
    batch.columns[0].values.should eq(["test", nil, nil, nil, nil])
    batch.columns[1].nulls.should eq([false, true, true, true, true])
    batch.columns[1].values.should eq([5, nil, nil, nil, nil])
  end
end