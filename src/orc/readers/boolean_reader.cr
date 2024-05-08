module Orc
  module Readers
    class BooleanReader < Base(Bool)
      def initialize(@reader : RunLengthBooleanReader)
      end

      def next
        @reader.next
      end
    end
  end
end