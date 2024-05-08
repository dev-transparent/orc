module Orc
  class StringDirectWriter
    def initialize(@length : RunLengthIntegerWriter, @data : IO)
    end

    def write(value : String)
      @data.write(value.to_slice)
      @length.write(value.bytesize)
    end

    def flush
      @length.flush
      @data.flush
    end
  end
end