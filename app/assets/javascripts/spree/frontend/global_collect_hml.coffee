($ document).ready ->
  $select          = ($ '.global-collect-pay-select')
  $link            = ($ '.global-collect-pay-link')
  $existing_cards  = ($ '.global-collect-reuse-profile')

  if $select.is('*')
    $select.change ->
      linkId = ($ this).data('link')
      $(linkId).data('payment-product', ($ this).val())

    $link.click (event) ->
      $existing_card_selected = $existing_cards.find('input:checked')
      paymentProduct = ($ this).data('payment-product')

      if $existing_card_selected.is('*')
        oldHref = ($ this).attr('href')
        reuseProfileParams = { global_collect: { profile_id: $existing_card_selected.val() } }

        ($ this).attr('href', "#{oldHref}&#{$.param(reuseProfileParams)}")
      else if paymentProduct
        oldHref = ($ this).attr('href')
        paymentProductParams = { global_collect: { payment_product: paymentProduct } }

        ($ this).attr('href', "#{oldHref}&#{$.param(paymentProductParams)}")
      else
        alert('Select a payment method first')
        event.preventDefault()
