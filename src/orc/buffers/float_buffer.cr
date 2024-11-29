module Orc
  struct FloatBuffer < Buffer(Float64)
    def append(value : Float64)
      value.to_io(@memory)
      @size += 1
    end

    def flush
      @memory.flush
    end
  end
end