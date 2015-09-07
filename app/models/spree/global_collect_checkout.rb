module Spree
  class GlobalCollectCheckout < ActiveRecord::Base
    has_one :payment, class_name: 'Spree::Payment', as: :source

    scope :with_payment_profile, -> { where('profile_token IS NOT NULL') }
    scope :valid,                -> { where('expiry_date > ?', Time.now.beginning_of_day) }

    def actions
      %w(capture)
    end

    def can_capture?(payment)
      (payment.pending? || payment.checkout?) && payment_product != "Sofort"
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

    def cc_last_four_digits=(credit_card)
      self[:cc_last_four_digits] = credit_card.try(:[], -4, 4)
    end

    def presentation
      Spree.t(:credit_card_profile, expiry_date: expiry_date.try(:strftime, '%m-%Y'), last_digits: cc_last_four_digits)
    end

    def credit_card_type
      payment_product_value = payment_product_id.to_s

      return 'Unkown type' unless GlobalCollect::Constants::PAYMENT_PRODUCTS.has_value?(payment_product_value)
      GlobalCollect::Constants::PAYMENT_PRODUCTS.key(payment_product_value)
    end

    def save_checkout_details(response)
      update_attributes(
        payment_product_id:   response[:paymentproductid],
        effort_id:            response[:effortid],
        attempt_id:           response[:attemptid],
        gc_payment_method_id: response[:paymentmethodid],
        payment_reference:    response[:paymentreference],
        cc_last_four_digits:  response[:creditcardnumber],
        expiry_date:          response[:expirydate]
      )
    end
  end
end
