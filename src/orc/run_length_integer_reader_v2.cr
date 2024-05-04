module Orc
  # The first byte of each group of values is a header that determines whether it is a run (value between 0 to 127) or literal list (value between -128 to -1). For runs, the control byte is the length of the run minus the length of the minimal run (3) and the control byte for literal lists is the negative length of the list. For example, a hundred 0’s is encoded as [0x61, 0x00] and the sequence 0x44, 0x45 would be encoded as [0xfe, 0x44, 0x45]. The next group can choose either of the encodings.
  class RunLengthIntegerReaderV2
    include Iterator(Int64)

    MIN_REPEAT_SIZE = 3

    enum EncodingType
      ShortRepeat
      Direct
      PatchBase
      Delta
    end

    private property literals : StaticArray(Int64, 128)
    private property literals_size : Int32 = 0
    private property used : Int32 = 0
    private property repeat : Bool = false
    private property signed : Bool
    private property! current_encoding : EncodingType?

    def initialize(@io : IO, @signed : Bool = false)
      @literals = uninitialized Int64[128]
    end

    def read
      @used = 0
      @literals_size = 0
      @repeat = false

      first_byte = @io.read_byte.not_nil!

      @current_encoding = EncodingType.new(first_byte.to_i32 >> 6 & 0x03)

      case @current_encoding
      when EncodingType::ShortRepeat
        read_short_repeat(first_byte)
      when EncodingType::Direct
        read_direct(first_byte)
      else
        raise "not supported"
      end
    end

    def read_direct(first_byte : UInt8)
      encoded_width = (first_byte.to_u64 >> 1) & 0x1f
      width = decode_width(encoded_width)

      length = ((first_byte.to_u64 & 0x01) << 8)
      second_byte = @io.read_byte.not_nil!
      length |= second_byte
      length += 1

      read_ints(@literals_size, length, width)

      if signed
        length.times do |i|
          @literals[@literals_size] = zigzag_decode(@literals[@literals_size])
          @literals_size += 1
        end
      else
        @literals_size = length.to_i32
      end
    end

    def read_ints(offset, length, width)
      case width
      when 16
        unpack_rolled_bytes(offset, length, 2)
      when 64
        unpack_rolled_bytes(offset, length, 8)
      else
        raise "unsupported integer encoding width #{width}"
      end
    end

    def unpack_rolled_bytes(offset, length, num_bytes)
      num_hops = 8
      remainder = length % num_hops
      end_offset = offset + length
      end_unroll = end_offset - remainder

      j = 0
      i = offset
      while i < end_unroll
        read_long_be(i, num_hops, num_bytes)
        i += num_hops * num_bytes
        j += 1
      end

      if remainder > 0
        read_remaining_longs(i, remainder, num_bytes)
      end
    end

    def read_remaining_longs(offset, remainder, num_bytes)
      to_read = remainder * num_bytes

      read_buffer = Bytes.new(64) # TODO: Constant number
      to_read.times do |i|
        read_buffer[i] = @io.read_byte.not_nil!
      end

      index = 0
      case num_bytes
      when 2
        while remainder > 0
          @literals[offset] = read_long_be2(read_buffer, index * 2)
          offset += 1
          remainder -= 1
          index += 1
        end
      when 8
        while remainder > 0
          @literals[offset] = read_long_be8(read_buffer, index * 8)
          offset += 1
          remainder -= 1
          index += 1
        end
      end
    end

    def read_long_be(start, num_hops, num_bytes)
      to_read = num_hops * num_bytes

      read_buffer = Bytes.new(64) # TODO: Constant number
      # @io.read_fully(read_buffer)
      to_read.times do |i|
        read_buffer[i] = @io.read_byte.not_nil!
      end

      case num_bytes
      when 8
        @literals[start + 0] = read_long_be8(read_buffer, 0)
        @literals[start + 1] = read_long_be8(read_buffer, 8)
        @literals[start + 2] = read_long_be8(read_buffer, 16)
        @literals[start + 3] = read_long_be8(read_buffer, 24)
        @literals[start + 4] = read_long_be8(read_buffer, 32)
        @literals[start + 5] = read_long_be8(read_buffer, 40)
        @literals[start + 6] = read_long_be8(read_buffer, 48)
        @literals[start + 7] = read_long_be8(read_buffer, 56)
      end
    end

    def read_long_be2(read_buffer : Bytes, offset)
      return (((read_buffer[offset] & 255).to_i64 << 8) +
        ((read_buffer[offset + 1] & 255).to_i64 << 0))
    end

    def read_long_be8(read_buffer : Bytes, offset)
      return (((read_buffer[offset] & 255).to_i64 << 56) +
        ((read_buffer[offset + 1] & 255).to_i64 << 48) +
        ((read_buffer[offset + 2] & 255).to_i64 << 40) +
        ((read_buffer[offset + 3] & 255).to_i64 << 32) +
        ((read_buffer[offset + 4] & 255).to_i64 << 24) +
        ((read_buffer[offset + 5] & 255).to_i64 << 16) +
        ((read_buffer[offset + 6] & 255).to_i64 << 8) +
        ((read_buffer[offset + 7] & 255).to_i64 << 0))
    end

    def decode_width(encoded_width : UInt64)
      case encoded_width
      when 0
        1
      when 1
        2
      when 3
        4
      when 7
        8
      when 15
        16
      when 23
        24
      when 27
        32
      when 28
        40
      when 29
        48
      when 30
        56
      when 31
        64
      else
        raise "Decoding direct width failed for #{encoded_width}"
      end
    end

    def read_short_repeat(first_byte : UInt8)
      size = (first_byte.to_i32 >> 3) & 0x07
      size += 1

      length = (first_byte & 0x07).to_i
      length += MIN_REPEAT_SIZE

      slice = Bytes.new(size)
      @io.read_fully(slice)

      value = bytes_to_big_endian(slice.reverse!, size)

      if signed
        value = zigzag_decode(value)
      end

      @repeat = true

      length.times do |i|
        @literals[i] = value
      end

      @literals_size = length
    end

    def bytes_to_big_endian(bytes : Bytes, size : Int32) : Int64
      result = 0_i64
      value = 0_i64
      size.times do |i|
        value = bytes[i].to_i64
        result |= value << (i * 8).to_i64
      end

      result
    end

    def zigzag_decode(value : Int64)
      ((value >> 1) ^ (value & 1) << 63) >> 63
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