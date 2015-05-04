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

    def expiry_date=(date)
      month, year = date.try(:scan, /.{1,2}/)

      self[:expiry_date] = Date.strptime("#{year}-#{month}", '%y-%m')
                           .end_of_month if month.present? && year.present?
    end

    def presentation
      "Credit card with token: #{profile_token}"
    end
  end
end
