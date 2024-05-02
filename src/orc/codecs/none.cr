module Orc
  module Codecs
    class None < Codec
      def encode(io : IO) : IO
        io
      end

      def decode(io : IO) : IO
        io
      end
    end
  end
end