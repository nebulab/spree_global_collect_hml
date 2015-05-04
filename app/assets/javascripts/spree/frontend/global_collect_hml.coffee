($ document).ready ->
  $select = ($ '.global-collect-pay-select')
  $link   = ($ '.global-collect-pay-link')
  $reuse  = ($ '.global-collect-reuse-profile input:checked')

  if $select.is('*')
    $select.change ->
      linkId = ($ this).data('link')
      $(linkId).data('payment-product', ($ this).val())

    $link.click (event) ->
      paymentProduct = ($ this).data('payment-product')

      if $reuse.is('*')
        alert('reusing')
        oldHref = ($ this).attr('href')
        reuseProfileParams = { global_collect: { profile_id: $reuse.val() } }

        ($ this).attr('href', "#{oldHref}&#{$.param(reuseProfileParams)}")
      else if paymentProduct
        oldHref = ($ this).attr('href')
        paymentProductParams = { global_collect: { payment_product: paymentProduct } }

        ($ this).attr('href', "#{oldHref}&#{$.param(paymentProductParams)}")
      else
        alert('Select a payment method first')
        event.preventDefault()
