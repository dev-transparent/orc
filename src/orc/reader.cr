module Orc
  class Reader
    getter file : File
    getter io : IO

    delegate codec, to: file

    def initialize(@file : File, @io : IO)
    end

    def each_stripe : Nil
      StripeIterator.new(self).each do |stripe|
        yield stripe
      end
    end

    def each_stripe
      StripeIterator.new(self)
    end
  end
end
