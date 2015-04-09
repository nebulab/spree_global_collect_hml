($ document).ready ->
  $select = ($ '#global-collect-pay-select')
  $link   = ($ '#global-collect-pay-link')

  if $select.is('*') and $link.is('*')
    $select.change ->
      $link.data('payment-product', ($ this).val())

    $link.click (event) ->
      paymentProduct = ($ this).data('payment-product')

      if paymentProduct
        oldHref = ($ this).attr('href')
        paymentProductParams = { global_collect: { payment_product: paymentProduct } }

        ($ this).attr('href', "#{oldHref}&#{$.param(paymentProductParams)}")
      else
        alert('Select a payment method first')
        event.preventDefault()