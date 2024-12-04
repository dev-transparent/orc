module Orc
  struct StringBuffer < Buffer(String)
    def append(value : String)
      @memory.write(vaue.to_slice)
    end

    def flush
      @memory.flush
    end
  end
end