module Orc
  class StringDictionaryWriter
    def initialize(@length : RunLengthIntegerWriter, @dictionary : RunLengthIntegerWriter, @data : IO)
      @last_index = 0
      @mapping = {} of String => Int64
    end

    def write(value : String)
      index = @mapping[value]? || begin
        @data.write(value.to_slice)
        @length.write(value.bytesize.to_i64)

        @last_index.tap do
          @mapping[value] = @last_index
          @last_index += 1
        end
      end

      @dictionary.write(index.to_i64)
    end

    def flush
      @length.flush
      @dictionary.flush
      @data.flush
    end
  end
end