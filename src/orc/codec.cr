module Orc
  abstract class Codec
    abstract def encode(io : IO) : IO
    abstract def decode(io : IO) : IO
  end
end

require "./codecs/**"