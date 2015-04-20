module Spree
  class GlobalCollectCheckout < ActiveRecord::Base
    has_one :payment, class_name: 'Spree::Payment', as: :source

    def payment_product
      payment.payment_method.payment_product_from_id(payment_product_id)
    end
  end
end
