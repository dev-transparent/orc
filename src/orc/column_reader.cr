module Orc
  class BaseColumnReader
  end

  class ColumnReader(T) < BaseColumnReader
    include Iterator(T | Nil)

    def initialize(@reader : Readers::Base(T), @presence : RunLengthBooleanReader?)
    end

    def to_vector(vector : Vector(T | Nil))
      each_with_index do |item, index|
        vector[index] = item
      end
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