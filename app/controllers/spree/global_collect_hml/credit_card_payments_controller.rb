module Spree
  class GlobalCollectHml::CreditCardPaymentsController < StoreController
    before_filter { current_order || fail(ActiveRecord::RecordNotFound) }

    def create
      redirect_to Gateway::GlobalCollectHml::CreditCard.prepare(current_order)
    end
  end
end
