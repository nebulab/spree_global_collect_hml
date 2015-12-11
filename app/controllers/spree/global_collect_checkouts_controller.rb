module Spree
  class GlobalCollectCheckoutsController < BaseController
    before_filter :log_request, :load_global_collect_checkout,
                  :load_order, :load_payment
    skip_before_action :verify_authenticity_token, only: :create

    rescue_from Spree::Core::GatewayError, with: :render_nok

    def create
      return render(nothing: true) unless status_successful?
      return render_ok             if @payment.try(:completed?)

      if @payment.present? && @payment.can_complete? && @payment.complete!
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
      @payment = @global_collect_checkout.payment || create_payment_from_webhook
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

      success_status_codes = [
        800,  # READY
        1000, # PAID
        1050, # COLLECTED (used by Sofort)
      ]

      success_status_codes.include?(params['STATUSID'].to_i)
    end

    # A webhook is received from GlobalCollect which we don't have payments for.
    # This can happen when user closes the browser window after submit the
    # payment but before coming back to the site (which will actually create
    # the Spree::Payment in our system).
    def create_payment_from_webhook
      return nil if @order.nil? || !status_successful?

      Spree::Order.transaction do
        payment = @order.payments.create!(
          source: @global_collect_checkout,
          amount: @order.total,
          payment_method: @global_collect_checkout.payment_method,
        )

        # Also complete the order if needed
        @order.next if @order.can_go_to_state?('complete')

        payment
      end
    end
  end
end
