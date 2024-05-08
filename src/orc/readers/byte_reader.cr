module Orc
  module Readers
    class ByteReader < Base(UInt8)
      def initialize(@reader : RunLengthByteReader)
      end

      def next
        @reader.next
      end
    end
  end
end