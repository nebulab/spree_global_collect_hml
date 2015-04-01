module Spree
  class Gateway::GlobalCollectHml::CreditCard < Gateway
    preference :merchant_id, :string

    def method_type
      'global_collect_hml_credit_card'
    end

    def supports?(source)
      true
    end

    def auto_capture?
      true
    end

    def purchase
      # TODO: implement... this needs to be called when Global Collect calls the
      #       application server back to notify everything is ok
    end

    def self.prepare(order)
      # INSERT_ORDERWITHPAYMENT goes here
    end
  end
end
