module Orc
  # Similar to Array but has no bounds checking at all and is very unsafe... but performant
  class Vector(T)
    getter size : Int32

    def initialize(@buffer : Pointer(T), @size : Int32)
    end

    def initialize(@size : Int32)
      @buffer = Pointer(T).new(@size)
    end

    @[AlwaysInline]
    def [](index)
      @buffer[index]
    end

    @[AlwaysInline]
    def []=(index, value)
      @buffer[index] = value
    end
  end
end