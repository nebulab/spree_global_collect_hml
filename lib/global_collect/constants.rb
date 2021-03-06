module GlobalCollect
  module Constants
    PAYMENTS_TEST_URL = 'https://ps.gcsip.nl/wdl/wdl'
    PAYMENTS_LIVE_URL = 'https://ps.gcsip.com/wdl/wdl'

    CONSOLE_TEST_URL = 'https://wpc.gcsip.nl/wpc'
    CONSOLE_LIVE_URL = 'https://wpc.gcsip.com/wpc'

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

    ERRORS = {
      '430285' => 'Not authorised',
      '430396' => 'Not authorised',
      '430360' => 'Not authorised',
      '430490' => 'Not authorised',
      '430330' => 'Not authorised',
      '430475' => 'Not authorised',
      '430421' => 'Not authorised',
      '430450' => 'Not authorised',
      '430390' => 'Unable to authorise',
      '430309' => 'Unable to authorise',
      '430306' => 'Card expired',
      '430409' => 'Referred'
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
