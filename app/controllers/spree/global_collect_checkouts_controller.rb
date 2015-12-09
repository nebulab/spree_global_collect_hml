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
        Order.transaction do
          order = Order.find(params['ORDERID'])

          global_collect_checkout = GlobalCollectCheckout.create(
            order_number:   order.global_collect_number,
            order:          order,
            user_id:        order.user_id,
            payment_method_id: params[:global_collect][:payment_method_id],
          )

          order.payments.create!(
            source: global_collect_checkout,
            amount: order.total,
            payment_method_id: global_collect_checkout.payment_method_id,
          )

          order.next

          if order.complete?
            render_ok
          else
            # this will let webhooks continue trigger us until the
            # payment is flagged as completed
            render_nok
          end
        end
      end
    end

    private

    def log_request
      request_log = Spree.t('global_collect.debug_webhook', params: params)

      Rails.logger.info(request_log)
    end

    def load_global_collect_checkout
      @global_collect_checkout = GlobalCollectCheckout.find_by_order_number(params['ORDERID'])
    end

    def load_payment
      @payment = @global_collect_checkout.try(:payment)
    end

    def load_order
      @order = @global_collect_checkout.try(:order)
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
