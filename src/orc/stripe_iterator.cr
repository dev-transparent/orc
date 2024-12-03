module Orc
  class StripeIterator
    include Iterator(Stripe)

    private getter reader : Reader
    private getter stripes : Array(Proto::StripeInformation)
    private property current_index = 0

    delegate file, to: reader

    def initialize(@reader : Reader)
      @stripes = reader.footer.stripes.not_nil!
    end

    def next
      if current_index < stripes.size
        stripe_information = stripes[@current_index]

        Stripe.from_reader(reader, stripe_information).tap do
          @current_index += 1
        end
      else
        stop
      end
    end
  end
end