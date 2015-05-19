Spree::Admin::PaymentsHelper.module_eval do
  def global_collect_payment_url(payment)
    console_url = if payment.payment_method.preferred_test_mode
                    GlobalCollect::Constants::CONSOLE_TEST_URL
                  else
                    GlobalCollect::Constants::CONSOLE_LIVE_URL
                  end

    params = {
      merchantId: payment.payment_method.preferred_merchant_id,
      orderId: payment.source.order_number,
      effortId: payment.source.effort_id,
      attemptId: payment.source.attempt_id,
      paymentProductId: payment.source.payment_product_id,
      paymentMethodId: payment.source.gc_payment_method_id,
      paymentReference: payment.source.payment_reference
    }

    "#{console_url}/generateOrderDetails.htm?#{params.to_query}"
  end
end
