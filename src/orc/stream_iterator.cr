module Orc
  class StreamIterator
    include Iterator(Stream)

    def next
      stop
    end
  end
end