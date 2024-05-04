module Orc
  module Writers
    class BooleanColumn
      def initialize(column : UInt32)
        @data_stream = Orc::Stream.new(Orc::Codecs::None.new, column, Orc::Proto::Stream::Kind::DATA)
        @writer = Orc::RunLengthBooleanWriter.new(@data_stream.buffer)
      end

      def write(value : Bool)
        @writer.write(value)
      end

      def flush
        @writer.flush
      end

      def streams : Array(Stream)
        [@data_stream]
      end
    end
  end
end