require "../spec_helper"

describe Orc::RunLengthIntegerReaderV2 do
  it "decodes short repeat" do
    decoded = Orc::RunLengthIntegerReaderV2.new(IO::Memory.new(Bytes[0x0a, 0x27, 0x10])).to_a
    decoded.should eq([10000, 10000, 10000, 10000, 10000])
  end

  it "decodes direct" do
    decoded = Orc::RunLengthIntegerReaderV2.new(IO::Memory.new(Bytes[0x5e, 0x03, 0x5c, 0xa1, 0xab, 0x1e, 0xde, 0xad, 0xbe, 0xef])).to_a
    decoded.should eq([23713, 43806, 57005, 48879])
  end
end