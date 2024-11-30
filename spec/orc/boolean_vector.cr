require "../spec_helper"

describe Orc::BooleanVector do
  it "stores null values" do
    vector = Orc::BooleanVector.new(5)
    vector.nulls[0] = false

    vector.nulls[0].should be_false
  end
end