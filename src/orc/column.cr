module Orc
  abstract class Column(T)
    include Iterator(T | Nil)

    @present : RunLengthBooleanReader?

    def present?
      if reader = @present
        reader.next
      else
        true
      end
    end
  end
end