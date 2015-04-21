module Spree
  class Gateway::GlobalCollectHml < Gateway
    TEST_URL = 'https://ps.gcsip.nl/wdl/wdl'
    LIVE_URL = 'https://ps.gcsip.com/wdl/wdl'

    preference :merchant_id, :string
    preference :test_mode, :boolean, default: false
    preference :payment_products, :hash, default: {
      'Visa'             => '1',
      'Visa Debit'       => '114',
      'MasterCard'       => '3',
      'MasterCard Debit' => '119',
      'American Express' => '2',
      'Maestro'          => '117',
      'Sofort'           => '836',
      'SEPA'             => '770'
    }
    preference :payment_product_restrictions, :hash, default: {
      '117' => {
        'currency'  => %w(EUR),
        'countries' => %w(AL AD AM AT BY BE BA BG CH CY CZ DE DK EE ES FO FI FR
                          GB GE GI GR HU HR IE IS IT LT LU LV MC MK MT NO NL PL
                          PT RO RU SE SI SK SM TR UA VA)
      },
      '836' => {
        'currency' => %w(EUR),
        'countries' => %w(AT BE CH DE FR GB NL PL)
      },
      '770' => {
        'currency' => %w(EUR),
        'countries' => %w(AT BE DE ES FR IT NL)
      }
    }

    def method_type
      'global_collect_hml'
    end

    def supports?(source)
      true
    end

    def auto_capture?
      true
    end

    def provider
      self
    end

    def purchase(amount, source, gateway_options={})
      response = provider.get_orderstatus(source.order_number)

      if response.success?
        source.update_attributes(
          payment_product_id: response[:paymentproductid],
          effort_id: response[:effortid],
          attempt_id: response[:attemptid],
          payment_method_id: response[:paymentmethodid],
          payment_reference: response[:paymentreference]
        )

        class << response
          def authorization; nil; end
        end
        response
      else
        class << response
          def success?; false; end
          def authorization; nil; end
          def to_s
            error || Spree.t('global_collect.payment_error')
          end
        end
        response
      end
    end

    def filtered_product_payments(order)
      return preferred_payment_products if payment_product_unrestricted?

      preferred_payment_products.select do |_, value|
        restriction = preferred_payment_product_restrictions[value]

        restriction.nil? ||
          (restriction['currency'].include?(order.currency) &&
          restriction['countries'].include?(order.bill_address_country.try(:iso)))
      end
    end

    def payment_product_from_id(payment_product_id)
      preferred_payment_products.invert[payment_product_id.to_s]
    end

    def get_orderstatus(order_number)
      global_collect.call(:get_orderstatus, order: { orderid: order_number })
    end

    def insert_orderwithpayment(order, payment_product_id, return_url)
      case payment_product_from_id(payment_product_id)
      when 'SEPA'
        pay_with_sepa(order, payment_product_id, return_url)
      else
        pay_with_default(order, payment_product_id, return_url)
      end
    end

    private

    def pay_with_default(*args)
      global_collect.call(
        :insert_orderwithpayment,
        order: credit_card_order_params(*args),
        payment: credit_card_payment_params(*args)
      )
    end

    def pay_with_sepa(*args)
      global_collect.call(
        :insert_orderwithpayment,
        order: credit_card_order_params(*args),
        payment: credit_card_payment_params(*args)
                 .merge(sepa_payment_params)
      )
    end

    def sepa_payment_params
      {
        transactiontype: 'S',
        directdebittext: "SEPA Payment for #{Spree::Config.site_name}"
      }
    end

    def credit_card_order_params(order, payment_product_id, return_url)
      {
        orderid: order.global_collect_number,
        merchantreference: rand(Time.now.to_i).to_s.slice(0..29),
        amount: order.global_collect_total,
        currencycode: order.currency,
        countrycode: order.bill_address_country.try(:iso),
        firstname: order.bill_address_global_collect_firstname,
        surname: order.bill_address_global_collect_surname,
        street: order.bill_address_global_collect_street,
        zip: order.bill_address_zipcode,
        city: order.bill_address_global_collect_city,
        state: order.bill_address_state_text,
        email: order.email,
        ipaddresscustomer: order.last_ip_address,
        languagecode: 'en',
        returnurl: return_url,
        paymentproductid: payment_product_id,
        shippingfirstname: order.ship_address_global_collect_firstname,
        shippingsurname: order.ship_address_global_collect_surname,
        shippingstreet: order.ship_address_global_collect_street,
        shippingzip: order.ship_address_zipcode,
        shippingcity: order.ship_address_global_collect_city,
        shippingstate: order.ship_address_state_text,
        shippingcountrycode: order.ship_address_country.try(:iso)
      }
    end

    def credit_card_payment_params(order, payment_product_id, return_url)
      {
        amount: order.global_collect_total,
        currencycode: order.currency,
        countrycode: order.bill_address_country.try(:iso),
        firstname: order.bill_address_global_collect_firstname,
        surname: order.bill_address_global_collect_surname,
        street: order.bill_address_global_collect_street,
        zip: order.bill_address_zipcode,
        state: order.bill_address_state_text,
        email: order.email,
        languagecode: 'en',
        returnurl: return_url,
        customeripaddress: order.last_ip_address,
        paymentproductid: payment_product_id,
        hostedindicator: 1
      }
    end

    def payment_product_unrestricted?
      (preferred_payment_products.invert.keys -
        preferred_payment_product_restrictions.keys).empty?
    end

    def endpoint_url
      preferred_test_mode ? TEST_URL : LIVE_URL
    end

    def global_collect
      @gc ||= GlobalCollectRequest.new(endpoint_url, preferred_merchant_id)
    end
  end
end
