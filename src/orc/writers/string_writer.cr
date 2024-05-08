require "./base"

module Orc
  module Writers
    class StringWriter < Base(String)
      def initialize(@writer : StringDictionaryWriter | StringDirectWriter)
      end

      def write(value : String)
        @writer.write(value)
      end

      def flush
        @writer.flush
      end
    end
  end
end