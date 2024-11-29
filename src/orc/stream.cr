module Orc
  abstract class Stream
    abstract def bytesize
    abstract def flush
    abstract def to_io(io)
  end
end

require "./streams/**"