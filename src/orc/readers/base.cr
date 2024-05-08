module Orc
  module Readers
    abstract class Base(T)
      include Iterator(T)
    end
  end
end