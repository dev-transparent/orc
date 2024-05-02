module Orc
  abstract class StringReader
    include Iterator(String)
  end
end