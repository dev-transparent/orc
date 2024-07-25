require "../spec_helper"

describe Orc::Vector do
  it "supports String" do
    vector = Orc::Vector(String).new(100)
    vector[0] = "Hello"
    vector[1] = "World"

    vector[0].should eq("Hello")
    vector[1].should eq("World")
    vector.size.should eq(100)
  end

  it "supports Bool" do
    vector = Orc::Vector(Bool).new(100)
    vector[0] = true
    vector[1] = false

    vector[0].should eq(true)
    vector[1].should eq(false)
    vector.size.should eq(100)
  end

  it "supports Int64" do
    vector = Orc::Vector(Int64).new(100)
    vector[0] = 5463
    vector[1] = 435634563456

    vector[0].should eq(5463)
    vector[1].should eq(435634563456)
    vector.size.should eq(100)
  end
end