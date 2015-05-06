module GlobalCollect
  module Constants
    TEST_URL = 'https://ps.gcsip.nl/wdl/wdl'
    LIVE_URL = 'https://ps.gcsip.com/wdl/wdl'

    PAYMENT_PRODUCTS = {
      'Visa'             => '1',
      'Visa Debit'       => '114',
      'MasterCard'       => '3',
      'MasterCard Debit' => '119',
      'American Express' => '2',
      'Maestro'          => '117',
      'Sofort'           => '836',
      'SEPA'             => '770',
      'Bank Transfer'    => '11'
    }

    PAYMENT_PRODUCTS_RESTRICTIONS = {
      PAYMENT_PRODUCTS['Maestro'] => {
        'currency'  => %w(EUR),
        'countries' => %w(AL AD AM AT BY BE BA BG CH CY CZ DE DK EE ES FO FI FR
                          GB GE GI GR HU HR IE IS IT LT LU LV MC MK MT NO NL PL
                          PT RO RU SE SI SK SM TR UA VA)
      },
      PAYMENT_PRODUCTS['Sofort'] => {
        'currency' => %w(EUR),
        'countries' => %w(AT BE CH DE FR GB NL PL)
      },
      PAYMENT_PRODUCTS['SEPA'] => {
        'currency' => %w(EUR),
        'countries' => %w(AT BE DE ES FR IT NL)
      }
    }
  end
end
