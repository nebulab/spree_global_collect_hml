module Spree
  class GlobalCollectHml::CreditCardPaymentsController < StoreController
    before_filter { current_order || fail(ActiveRecord::RecordNotFound) }

    def create
      order = current_order || raise(ActiveRecord::RecordNotFound)

      begin
        response = provider.insert_orderwithpayment(order)[:xml][:request][:response]

        if response[:result] == 'OK'
          redirect_to response[:row][:formaction]
        else
          flash[:error] = Spree.t('flash.generic_error')
          redirect_to checkout_state_path(:payment)
        end
      rescue
        flash[:error] = Spree.t('flash.connection_failed')
        redirect_to checkout_state_path(:payment)
      end
    end

    private

    def payment_method
      Spree::PaymentMethod.find(params[:payment_method_id])
    end

    def provider
      payment_method.provider
    end
  end
end
