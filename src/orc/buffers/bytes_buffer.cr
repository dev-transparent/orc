module Orc
  struct BytesBuffer < Buffer(Bytes)
    def append(value : Bytes)
      @memory.write(value)
      @size += 1
    end

    def flush
      @memory.flush
    end
  end
end