module Orc
  struct BytesBuffer < Buffer(Bytes)
    def append(value : Bytes)
      @memory.write(value)
    end

    def flush
      @memory.flush
    end
  end
end