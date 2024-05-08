module Orc
  class ColumnReader(T)
    include Iterator(T | Nil)

    def initialize(@reader : Readers::Base(T), @presence : RunLengthBooleanReader?)
    end

    def next
      return nil unless present?

      @reader.next
    end

    private def present?
      if presence_reader = @presence
        presence_reader.next
      else
        true
      end
    end
  end
end