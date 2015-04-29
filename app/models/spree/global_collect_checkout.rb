module Spree
  class GlobalCollectCheckout < ActiveRecord::Base
    has_one :payment, class_name: 'Spree::Payment', as: :source
    attr_accessible :order_number, :effort_id, :attempt_id,
                    :payment_method_id, :payment_reference,
                    :payment_product_id

    def actions
      %w(capture)
    end

    def can_capture?(payment)
      payment.pending? || payment.checkout?
    end

    def payment_product
      payment.payment_method.payment_product_from_id(payment_product_id)
    end
  end
end
