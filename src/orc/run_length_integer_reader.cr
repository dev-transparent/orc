module Orc
  class RunLengthIntegerReader
    include Iterator(Int64)

    private property literals : StaticArray(Int64, 128)
    private property literals_size : Int32 = 0
    private property used : Int32 = 0
    private property repeat : Bool = false
    private property signed : Bool

    @delta : Int32 = 0

    def initialize(@io : IO, @signed : Bool = false)
      @literals = uninitialized Int64[128]
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
        @literals[0] + @used * @delta
      else
        @literals[@used]
      end

      @used += 1

      result
    end

    def read
      control = @io.read_byte.not_nil!

      @used = 0

      if control < 0x80
        @literals_size = control.to_i + 3
        @repeat = true

        @delta = @io.read_byte.not_nil!.to_i8!.to_i32

        if signed
          @literals[0] = read_vs_long
        else
          @literals[0] = read_vu_long
        end
      else
        @repeat = false
        @literals_size = 0x100 - control.to_i
        @literals_size.times do |i|
          if signed
            @literals[i] = read_vs_long
          else
            @literals[i] = read_vu_long
          end
        end
      end
    end

    def read_vs_long
      result = read_vu_long
      ((result.to_u64 >> 1.to_u64) ^ ((result.to_u64 & 1.to_u64)).to_i64 * -1).to_i64!
    end

    def read_vu_long
      result = 0i64
      offset = 0i64
      b = 0x80.to_i64

      while b & 0x80 != 0
        b = @io.read_byte.not_nil!.to_i64

        if b == -1
          raise "Issue with unsigned vint"
        end

        result |= (b & 0x7f) << offset.to_u64
        offset += 7
      end

      result
    end
  end
end