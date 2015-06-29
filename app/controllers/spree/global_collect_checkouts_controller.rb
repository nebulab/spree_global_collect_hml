module Spree
  class GlobalCollectCheckoutsController < BaseController
    before_filter :log_request, :load_global_collect_checkout, :load_payment
    skip_before_action :verify_authenticity_token, only: :create

    rescue_from ActiveRecord::RecordNotFound, Spree::Core::GatewayError,
                with: :render_nok

    def create
      return render(nothing: true) unless params['STATUSID'].present? && params['STATUSID'].to_i >= 800

      if @payment.complete!
        render_ok
      else
        render_nok
      end
    end

    private

    def log_request
      request_log = Spree.t('global_collect.debug_webhook', params: params)

      Rails.logger.info(request_log)
    end

    def load_global_collect_checkout
      @global_collect_checkout = GlobalCollectCheckout.find_by_order_number!(params['ORDERID'])
    end

    def load_payment
      @payment = @global_collect_checkout.payment
    end

    def render_ok
      render plain: "OK\n"
    end

    def render_nok
      render plain: "NOK\n"
    end
  end
end
