module Spree
  class GlobalCollectHmlPaymentsController < StoreController
    before_filter :validate_current_order!, except: :complete
    before_filter :validate_ref_and_returnmac!, only: :confirm

    rescue_from Timeout::Error, Errno::EINVAL, Errno::ECONNRESET,
                EOFError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError,
                Net::ProtocolError, SocketError, with: :connection_errors

    def create
      @payment_method = payment_method

      @response = provider.insert_orderwithpayment(
        current_order,
        global_collect_params[:payment_product],
        global_collect_hml_payments_confirm_url(global_collect: {payment_method_id: @payment_method.id})
      )

      if @response.valid?
        store_global_collect_session_data(@response)
        redirect_to(@response[:formaction]) unless request.xhr?
      else
        flash[:error] = Spree.t('global_collect.connection_error')
        redirect_to checkout_state_path(current_order.state) unless request.xhr?
      end
    end

    def confirm
      @order = current_order

      @order.payments.create!(
        source: Spree::GlobalCollectCheckout.create(
          order_number: current_order.global_collect_number
        ),
        amount: current_order.total,
        payment_method: payment_method
      )

      @order.next

      render layout: false
    end

    def complete
      order = current_order || Spree::Order.find_by_number(params[:order_id])

      if order.complete?
        @current_order = nil
        flash.notice = Spree.t(:order_processed_successfully)
        flash['order_completed'] = true
        redirect_to order_path(order, token: order.guest_token)
      else
        flash[:error] = Spree.t('global_collect.payment_error')
        redirect_to checkout_state_path(order.state)
      end
    end

    private

    def connection_errors
      flash[:error] = Spree.t('flash.connection_failed')
      redirect_to checkout_state_path(current_order.state)
    end

    def store_global_collect_session_data(response)
      session['global_collect'] = {
        'ref' => response[:ref],
        'returnmac' => response[:returnmac]
      }
    end

    def validate_current_order!
      current_order || fail(ActiveRecord::RecordNotFound)
    end

    def validate_ref_and_returnmac!
      (session['global_collect']['ref'] == params['REF'] &&
        session['global_collect']['returnmac'] == params['RETURNMAC']) ||
        fail(ActiveRecord::RecordNotFound)
    end

    def payment_method
      Spree::PaymentMethod.find(global_collect_params[:payment_method_id])
    end

    def global_collect_params
      params[:global_collect]
    end

    def provider
      payment_method.provider
    end
  end
end
