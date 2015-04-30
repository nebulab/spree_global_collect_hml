module Spree
  class GlobalCollectCheckout < ActiveRecord::Base
    has_one :payment, class_name: 'Spree::Payment', as: :source

    scope :with_payment_profile, -> { where('profile_token IS NOT NULL') }

    def actions
      %w(capture)
    end

    def can_capture?(payment)
      payment.pending? || payment.checkout?
    end

    def has_payment_profile?
      profile_token.present?
    end

    def imported
      false
    end

    def payment_product
      payment.payment_method.payment_product_from_id(payment_product_id)
    end
  end
end
