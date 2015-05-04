module Spree
  class GlobalCollectCheckoutsController < ApplicationController
    before_filter :load_global_collect_checkout

    def update
      if @global_collect_checkout.update_attributes(global_collect_checkout_params)
        render plain: 'OK\n'
      else
        render plain: 'NOK\n'
      end
    end

    private

    def load_global_collect_checkout
      @global_collect_checkout = GlobalCollectCheckout.find_by_order_number!(params['ORDERID'])
    end

    def global_collect_checkout_params
      {
        cc_last_four_digits: params.fetch('CCLASTFOURDIGITS'),
        expiry_date:         params.fetch('EXPIRYDATE')
      }
    end
  end
end
