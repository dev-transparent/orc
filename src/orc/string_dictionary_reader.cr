module Orc
  class StringDictionaryReader
    include Iterator(String)

    @bytes : Bytes
    @lengths : Array(Int64) = [] of Int64
    @offsets : Array(Int64) = [] of Int64

    def initialize(@length : RunLengthIntegerReader, @dictionary : RunLengthIntegerReader, @data : IO)
      @bytes = @data.getb_to_end

      # Generate a list of lengths and offsets
      offset = 0
      @length.each do |length|
        @lengths << length
        @offsets << offset
        offset += length
      end
    end

    def next
      index = @dictionary.next

      case index
      when Int64
        String.new(@bytes[@offsets[index], @lengths[index]])
      when Iterator::Stop
        stop
      end
    end
  end
end