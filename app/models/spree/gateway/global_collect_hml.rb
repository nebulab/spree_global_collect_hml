module Spree
  class Gateway::GlobalCollectHml < Gateway
    include GlobalCollect::Constants

    preference :merchant_id, :string
    preference :test_mode, :boolean, default: false
    preference :avs_enabled, :boolean, default: false
    preference :payment_products, :hash, default: PAYMENT_PRODUCTS
    preference :payment_product_restrictions, :hash,
               default: PAYMENT_PRODUCTS_RESTRICTIONS

    has_many :global_collect_checkouts,
             class_name: 'Spree::GlobalCollectCheckout',
             foreign_key: 'payment_method_id'

    def method_type
      'global_collect_hml'
    end

    def provider_class
      provider.class
    end

    def provider
      self
    end

    def auto_capture?
      false
    end

    def payment_profiles_supported?
      true
    end

    def payment_source_class
      Spree::GlobalCollectCheckout
    end

    def reusable_sources(order)
      if order.completed?
        sources_by_order order
      else
        if order.user_id
          global_collect_checkouts
            .where(user_id: order.user_id).with_payment_profile.valid
        else
          []
        end
      end
    end

    def authorize(amount, source, gateway_options={})
      response    = provider.get_orderstatus(source.order_number)
      merchantref = response[:merchantreference]

      return ActiveMerchant::Billing::Response.new(
        false, "A source with merchant ref #{merchantref} already exists."
      ) if GlobalCollectCheckout.exists?(merchant_reference: merchantref)

      source.save_checkout_details(response)
      if response.success?
        ActiveMerchant::Billing::Response.new(
          true, Spree.t('global_collect.payment_authorized'),
          { gc_response: response.to_s },
          authorization: merchantref,
          avs_result: preferred_avs_enabled ? response.avs_result : nil,
          cvv_result: response.cvv_result
        )
      else
        ActiveMerchant::Billing::Response.new(
          false, response.error,
          { gc_response: response.to_s },
          avs_result: preferred_avs_enabled ? response.avs_result : nil,
          cvv_result: response.cvv_result
        )
      end
    end

    def capture(amount, source, gateway_options={})
      payment = Spree::Payment.find_by_response_code(source)

      response = provider.set_payment(
        payment.order.global_collect_number,
        payment.source.payment_product_id,
        payment.global_collect_amount
      )

      if response.valid?
        ActiveMerchant::Billing::Response.new(
          true, Spree.t('global_collect.payment_captured'),
          gc_response: response.to_s
        )
      else
        ActiveMerchant::Billing::Response.new(
          false, response.error,
          gc_response: response.to_s
        )
      end
    end

    def cancel(response_code)
      ActiveMerchant::Billing::Response.new(
        true,
        Spree.t('global_collect.payment_canceled')
      )
    end

    def create_profile(payment)
      return if payment.source.has_payment_profile?

      response = provider.convert_paymenttoprofile(payment.source.order_number)

      if response[:profiletoken].present?
        payment.source.update_attributes(profile_token: response[:profiletoken])
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

    def set_payment(order_number, payment_product_id, amount)
      global_collect.call(:set_payment, payment: {
        orderid: order_number, amount: amount,
        paymentproductid: payment_product_id
      })
    end

    def convert_paymenttoprofile(order_number)
      global_collect.call(:convert_paymenttoprofile, payment: { orderid: order_number })
    end

    def insert_orderwithpayment(order, payment_product_id, return_url, profile_id)
      case payment_product_from_id(payment_product_id)
      when 'SEPA'
        pay_with_sepa(order, payment_product_id, return_url, profile_id)
      else
        pay_with_default(order, payment_product_id, return_url, profile_id)
      end
    end

    private

    def pay_with_default(order, payment_product_id, return_url, profile_id)
      global_collect.call(
        :insert_orderwithpayment,
        order: credit_card_order_params(order, payment_product_id, return_url),
        payment: credit_card_payment_params(order, payment_product_id, return_url, profile_id)
      )
    end

    def pay_with_sepa(order, payment_product_id, return_url, profile_id)
      global_collect.call(
        :insert_orderwithpayment,
        order: credit_card_order_params(order, payment_product_id, return_url),
        payment: credit_card_payment_params(order, payment_product_id, return_url, profile_id)
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

    def credit_card_payment_params(order, payment_product_id, return_url, profile_id)
      hash_params = {
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

      if profile_id && profile = Spree::GlobalCollectCheckout.find(profile_id)
        hash_params[:paymentproductid] = profile.payment_product_id
        hash_params[:profiletoken]    = profile.profile_token
      end

      hash_params
    end

    def payment_product_unrestricted?
      (preferred_payment_products.invert.keys -
        preferred_payment_product_restrictions.keys).empty?
    end

    def endpoint_url
      preferred_test_mode ? PAYMENTS_TEST_URL : PAYMENTS_LIVE_URL
    end

    def global_collect
      @gc ||= GlobalCollect::Request.new(endpoint_url, preferred_merchant_id)
    end
  end
end
