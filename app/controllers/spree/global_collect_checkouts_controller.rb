module Spree
  class GlobalCollectCheckoutsController < ApplicationController
    before_filter :load_global_collect_checkout, :load_payment
    skip_before_action :verify_authenticity_token, only: :create

    rescue_from ActiveRecord::RecordNotFound, Spree::Core::GatewayError,
                with: :render_nok

    def create
      if @global_collect_checkout.can_capture?(@payment) && @payment.capture!
        render plain: "OK\n"
      else
        render_nok
      end
    end

    private

    def load_global_collect_checkout
      @global_collect_checkout = GlobalCollectCheckout.find_by_order_number!(params['ORDERID'])
    end

    def load_payment
      @payment = @global_collect_checkout.payment
    end

    def render_nok
      render plain: "NOK\n"
    end
  end
end
