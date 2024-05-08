module Orc
  module Readers
    class StringReader < Base(String)
      def initialize(@reader : StringDirectReader | StringDictionaryReader)
      end

      def next
        @reader.next
      end
    end
  end
end