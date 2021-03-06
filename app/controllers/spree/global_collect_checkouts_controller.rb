module Spree
  class GlobalCollectCheckoutsController < BaseController
    before_filter :log_request, :load_global_collect_checkout, :load_payment
    skip_before_action :verify_authenticity_token, only: :create

    rescue_from ActiveRecord::RecordNotFound, Spree::Core::GatewayError,
                with: :render_nok

    def create
      return render(nothing: true) unless status_successful?
      return render_ok             if @payment.completed?

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
      gc_checkout_params_conditions = { order_number: params['ORDERID'] }
      gc_checkout_params_conditions[:attempt_id] = params['ATTEMPTID'] if params['ATTEMPTID']

      @global_collect_checkout = GlobalCollectCheckout.where(gc_checkout_params_conditions).last!
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

    def status_successful?
      return false unless params['STATUSID'].present?

      # Successful if STATUSID is READY (800) or PAID (1000)
      params['STATUSID'].to_i == 800 || params['STATUSID'].to_i == 1000
    end
  end
end
