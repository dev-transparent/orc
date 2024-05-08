module Orc
  module Readers
    class IntegerReader < Base(Int64)
      def initialize(@reader : RunLengthIntegerReader | RunLengthIntegerReaderV2)
      end

      def next
        @reader.next
      end
    end
  end
end