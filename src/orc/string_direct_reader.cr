module Orc
  class StringDirectReader
    include Iterator(String)

    def initialize(@length : RunLengthIntegerReader, @data : IO)
    end

    def next
      case length = @length.next
      when Int64
        bytes = Bytes.new(length)
        @data.read(bytes)

        String.new(bytes)
      when Iterator::Stop
        stop
      end
    end
  end
end