require "../spec_helper"

describe Orc::RunLengthByteReader do
  it "decodes runs" do
    bytes = Bytes.new(2)
    bytes[0] = 0x02
    bytes[1] = 0x01

    decoded = Orc::RunLengthByteReader.new(IO::Memory.new(bytes)).to_a
    decoded.should eq([0x01, 0x01, 0x01, 0x01, 0x01])
  end

  it "decodes sequences" do
    bytes = Bytes.new(3)
    bytes[0] = 0xfe
    bytes[1] = 0x44
    bytes[2] = 0x45

    decoded = Orc::RunLengthByteReader.new(IO::Memory.new(bytes)).to_a
    decoded.should eq([0x44, 0x45])
  end
end