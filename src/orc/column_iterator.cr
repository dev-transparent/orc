module Orc
  class ColumnIterator(T)
    include Iterator(T)

    def initialize(@column : Column)
    end

    def next
      stop
    end
  end
end