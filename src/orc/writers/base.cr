module Orc
  module Writers
    abstract class Base(T)
      abstract def write(value : T)
      abstract def flush
    end
  end
end