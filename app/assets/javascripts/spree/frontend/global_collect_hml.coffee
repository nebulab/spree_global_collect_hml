($ document).ready ->
  linkClass = '.global-collect-pay-link'

  $select   = ($ '.global-collect-pay-select')
  $link     = ($ linkClass)

  if $select.is('*')
    $select.change ->
      elementId = ($ this).data('link')
      $("#{elementId}").data('payment-product', ($ this).val())

    $link.click (event) ->
      paymentProduct = ($ this).data('payment-product')

      if paymentProduct
        oldHref = ($ this).attr('href')
        paymentProductParams = { global_collect: { payment_product: paymentProduct } }

        ($ this).attr('href', "#{oldHref}&#{$.param(paymentProductParams)}")
      else
        alert('Select a payment method first')
        event.preventDefault()
