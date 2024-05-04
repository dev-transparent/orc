module Orc
  # Booleans are encoded as a RLE byte stream and therefore will return more booleans than there are rows in the stripe/stream.
  class RunLengthBooleanWriter
    private getter writer : Orc::RunLengthByteWriter

    def initialize(io : IO)
      @writer = Orc::RunLengthByteWriter.new(io)
      @data = 0u8
      @bits_in_data = 0
    end

    def write(bool : Bool)
      flush_bools if @bits_in_data >= 8

      if bool
        @data |= (1 << (7 - @bits_in_data).to_u8)
      end

      @bits_in_data += 1
    end

    def flush_bools
      return if @bits_in_data == 0
      writer.write(@data)

      @bits_in_data = 0
      @data = 0u8
    end

    def flush
      flush_bools
      writer.flush
    end

    def close
      flush
    end
  end
end