module Spree
  class GlobalCollectCheckoutsController < ApplicationController
    before_filter :load_global_collect_checkout, :load_payment
    skip_before_action :verify_authenticity_token, only: :create

    def create
      if @global_collect_checkout.can_capture?(@payment) && @payment.capture!
        render plain: 'OK\n'
      else
        render plain: 'NOK\n'
      end
    rescue Spree::Core::GatewayError
      render plain: 'NOK\n'
    end

    private

    def load_global_collect_checkout
      @global_collect_checkout = GlobalCollectCheckout.find_by_order_number!(params['ORDERID'])
    end

    def load_payment
      @payment = @global_collect_checkout.payment
    end
  end
end
