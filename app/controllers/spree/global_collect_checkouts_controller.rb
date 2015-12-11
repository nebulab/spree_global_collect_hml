module Spree
  class GlobalCollectCheckoutsController < BaseController
    before_filter :log_request, :load_global_collect_checkout, :load_payment,
                  :load_order
    skip_before_action :verify_authenticity_token, only: :create

    rescue_from Spree::Core::GatewayError, with: :render_nok

    def create
      return render(nothing: true) unless status_successful?
      return render_ok             if @payment.try(:completed?)

      if @payment.present?
        @payment.complete! ? render_ok : render_nok
      else
        Spree::Order.transaction do
          @order.payments.create!(
            source: @global_collect_checkout,
            amount: @order.total, payment_method: @global_collect_checkout.payment_method
          )

          @order.next || fail(ActiveRecord::Rollback)
        end
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

    def load_order
      @order = @global_collect_checkout.order
    end

    def render_ok
      render plain: "OK\n"
    end

    def render_nok
      render plain: "NOK\n"
    end

    def status_successful?
      return false unless params['STATUSID'].present?

      # Successful if STATUSID is READY (800) or PAID (1000)
      params['STATUSID'].to_i == 800 || params['STATUSID'].to_i == 1000
    end
  end
end
