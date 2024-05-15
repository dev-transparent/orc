module Orc
  module Writers
    abstract class Base(T)
      abstract def write(value : T)
      abstract def flush
      abstract def statistics
    end
  end
end