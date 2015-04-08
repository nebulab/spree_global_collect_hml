module Spree
  class GlobalCollectHml::CreditCardPaymentsController < StoreController
    before_filter :validate_current_order!
    before_filter :validate_ref_and_returnmac!, only: :confirm

    rescue_from Timeout::Error, Errno::EINVAL, Errno::ECONNRESET,
                EOFError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError,
                Net::ProtocolError, SocketError, with: :connection_errors

    def create
      response = provider.insert_orderwithpayment(current_order, global_collect_hml_credit_card_payments_confirm_url(payment_method_id: payment_method.id))

      if response && response[:result] == 'OK'
        store_global_collect_session_data(response)
        redirect_to response[:row][:formaction]
      else
        flash[:error] = Spree.t('flash.generic_error')
        redirect_to checkout_state_path(:payment)
      end
    end

    def confirm
      response = provider.get_orderstatus(current_order)

      if response && response[:result] == 'OK'
        provider.purchase(current_order)

        if current_order.complete?
          flash.notice = Spree.t(:order_processed_successfully)
          flash[:commerce_tracking] = "nothing special"
          session[:order_id] = nil
          redirect_to(completion_route(current_order)) and return
        end
      end

      redirect_to checkout_state_path(current_order.state)
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
