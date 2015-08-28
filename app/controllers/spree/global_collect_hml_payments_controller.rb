module Spree
  class GlobalCollectHmlPaymentsController < StoreController
    module Error
      class NotFound < StandardError; end
    end
    before_filter :validate_current_order!, except: [:complete, :confirm]
    before_filter :validate_ref_and_returnmac!, only: :confirm
    skip_before_action :verify_authenticity_token, only: :create

    rescue_from Timeout::Error, Errno::EINVAL, Errno::ECONNRESET,
                EOFError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError,
                Net::ProtocolError, SocketError, with: :connection_errors

    def create
      @payment_method = payment_method

      @response = provider.insert_orderwithpayment(
        current_order,
        global_collect_params[:payment_product],
        global_collect_hml_payments_confirm_url(
          global_collect: { spree_order_id: current_order.id, payment_method_id: @payment_method.id }),
        global_collect_params[:profile_id]
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
      @order = Order.find(global_collect_params[:spree_order_id])

      @order.payments.create!(
        source: GlobalCollectCheckout.create(
          order_number:      @order.global_collect_number,
          user_id:           @order.user_id,
          payment_method_id: payment_method.try(:id)
        ),
        amount: @order.total, payment_method: payment_method
      )
      @order.next

      if @order.errors[:base].any?
        flash[:error] = @order.errors.full_messages_for(:base).join(', ')
      end

      render layout: false
    end

    def complete
      order = current_order || Order.find_by_number(params[:order_id])

      if order.complete?
        @current_order = nil
        flash.notice = Spree.t(:order_processed_successfully)
        flash['order_completed'] = true
        redirect_to order_path(order, token: order.guest_token)
      else
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
      current_order || fail(Error::NotFound, 'current_order not found')
    end

    def validate_ref_and_returnmac!
      (session['global_collect']['ref'] == params['REF'] &&
        session['global_collect']['returnmac'] == params['RETURNMAC']) ||
        fail(Error::NotFound, 'Required Global Collect parameters not found')
    end

    def payment_method
      @pm ||= PaymentMethod.find(global_collect_params[:payment_method_id])
    end

    def global_collect_params
      params[:global_collect]
    end

    def provider
      payment_method.provider
    end
  end
end
