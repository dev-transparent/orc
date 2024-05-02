module Orc
  # Booleans are encoded as a RLE byte stream and therefore will return more booleans than there are rows in the stripe/stream.
  class RunLengthBooleanReader
    include Iterator(Bool)

    private getter reader : Orc::RunLengthByteReader
    private getter! data : UInt8?
    private getter bits_in_data = 0

    def initialize(io : IO)
      @reader = Orc::RunLengthByteReader.new(io)
    end

    def next
      if bits_in_data == 0
        case byte = @reader.next
        in Iterator::Stop
          return stop
        in UInt8
          @data = byte
          @bits_in_data = 8
        end
      end

      value = (data & 0x80) != 0
      value.tap do
        @data = data << 1
        @bits_in_data -= 1
      end
    end
  end
end