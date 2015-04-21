Spree::Admin::PaymentsHelper.module_eval do
  def global_collect_payment_url(payment)
    params = {
      merchant_id: payment.payment_method.preferred_merchant_id,
      order_id: payment.source.order_number,
      effort_id: payment.source.effort_id,
      attempt_id: payment.source.attempt_id,
      payment_product_id: payment.source.payment_product_id,
      payment_method_id: payment.source.payment_method_id,
      payment_reference: payment.source.payment_reference
    }

    "https://wpc.gcsip.nl/wpc/generateOrderDetails.htm?#{params.to_query}"
  end
end
