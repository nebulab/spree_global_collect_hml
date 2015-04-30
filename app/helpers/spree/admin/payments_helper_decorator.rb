Spree::Admin::PaymentsHelper.module_eval do
  def global_collect_payment_url(payment)
    params = {
      merchantId: payment.payment_method.preferred_merchant_id,
      orderId: payment.source.order_number,
      effortId: payment.source.effort_id,
      attemptId: payment.source.attempt_id,
      paymentProductId: payment.source.payment_product_id,
      paymentMethodId: payment.source.gc_payment_method_id,
      paymentReference: payment.source.payment_reference
    }

    "https://wpc.gcsip.nl/wpc/generateOrderDetails.htm?#{params.to_query}"
  end
end
