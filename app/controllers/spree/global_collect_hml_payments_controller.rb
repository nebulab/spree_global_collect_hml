module Spree
  class GlobalCollectHmlPaymentsController < StoreController
    before_filter :validate_current_order!
    before_filter :validate_ref_and_returnmac!, only: :confirm

    rescue_from Timeout::Error, Errno::EINVAL, Errno::ECONNRESET,
                EOFError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError,
                Net::ProtocolError, SocketError, with: :connection_errors

    def create
      response = provider.insert_orderwithpayment(current_order, global_collect_hml_payments_confirm_url(payment_method_id: payment_method.id))

      if response && response[:result] == 'OK'
        store_global_collect_session_data(response)
        @global_collect_url = response[:row][:formaction]

        respond_to do |format|
          format.html { redirect_to @global_collect_url }
          format.js
        end
      else
        flash[:error] = Spree.t('flash.generic_error')
        redirect_to checkout_state_path(:payment)
      end
    end

    def confirm
      current_order.payments.create!({
        source: Spree::GlobalCollectCheckout.create(
          order_number: current_order.global_collect_number
        ),
        amount: current_order.total,
        payment_method: payment_method
      })
      current_order.next

      if current_order.complete?
        flash.notice = Spree.t(:order_processed_successfully)
        flash[:commerce_tracking] = "nothing special"
        session[:order_id] = nil
        redirect_to order_path(current_order, token: current_order.guest_token)
      else
        redirect_to checkout_state_path(current_order.state)
      end
    end

    private

    def connection_errors
      flash[:error] = Spree.t('flash.connection_failed')
      redirect_to checkout_state_path(current_order.state)
    end

    def store_global_collect_session_data(response)
      session[:global_collect] = {
        ref: response[:row][:ref],
        returnmac: response[:row][:returnmac]
      }
    end

    def validate_current_order!
      current_order || fail(ActiveRecord::RecordNotFound)
    end

    def validate_ref_and_returnmac!
      (session[:global_collect]['ref'] == params['REF'] &&
        session[:global_collect]['returnmac'] == params['RETURNMAC']) ||
        fail(ActiveRecord::RecordNotFound)
    end

    def payment_method
      Spree::PaymentMethod.find(params[:payment_method_id])
    end

    def provider
      payment_method.provider
    end
  end
end