module Orc
  # The first byte of each group of values is a header that determines whether it is a run (value between 0 to 127) or literal list (value between -128 to -1). For runs, the control byte is the length of the run minus the length of the minimal run (3) and the control byte for literal lists is the negative length of the list. For example, a hundred 0’s is encoded as [0x61, 0x00] and the sequence 0x44, 0x45 would be encoded as [0xfe, 0x44, 0x45]. The next group can choose either of the encodings.
  class RunLengthByteReader
    include Iterator(UInt8)

    MIN_REPEAT_SIZE = 3
    MAX_LITERAL_SIZE = 128

    private property literals : StaticArray(UInt8, 128)
    private property literals_size : Int32 = 0
    private property used : Int32 = 0
    private property repeat : Bool = false

    def initialize(@io : IO)
      @literals = uninitialized UInt8[128]
    end

    def read
      @used = 0

      control = @io.read_byte.not_nil!

      if control < 0x80 # Run
        @repeat = true
        @literals_size = control.to_i + MIN_REPEAT_SIZE
        @literals[0] = @io.read_byte.not_nil!
      else # Literal list
        @repeat = false
        @literals_size = 0x100 - control.to_i

        @literals_size.times do |i|
          @literals[i] = @io.read_byte.not_nil!
        end
      end
    end

    def has_next?
      @used != @literals_size || !@io.peek.try &.empty?
    end

    def next
      return stop unless has_next?

      if @used == @literals_size
        read
      end

      result = if @repeat
        @literals[0]
      else
        @literals[@used]
      end

      @used += 1

      result
    end
  end
end