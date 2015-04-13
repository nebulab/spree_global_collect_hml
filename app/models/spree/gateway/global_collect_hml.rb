module Spree
  class Gateway::GlobalCollectHml < Gateway
    TEST_URL = 'https://ps.gcsip.nl/wdl/wdl'
    LIVE_URL = 'https://ps.gcsip.com/wdl/wdl'

    preference :merchant_id, :string
    preference :test_mode, :boolean, default: false
    preference :payment_products, :hash, default: {
      visa: 1, mastercard: 3
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

      if response.paid?
        Class.new do
          def success?; true; end
          def authorization; nil; end
        end.new
      else
        Class.new do
          def success?; false; end
          def to_s; Spree.t('global_collect.payment_error'); end
        end.new
      end
    end

    def get_orderstatus(order_number)
      global_collect.call(:get_orderstatus, order: { orderid: order_number })
    end

    def insert_orderwithpayment(order, payment_product, return_url)
      global_collect.call(:insert_orderwithpayment,
        order: {
          orderid: order.global_collect_number,
          merchantreference: rand(Time.now.to_i).to_s.slice(0..29),
          amount: order.global_collect_total,
          currencycode: order.currency,
          countrycode: order.bill_address.country.iso,
          firstname: order.bill_address.firstname,
          surname: order.bill_address.lastname,
          languagecode: 'en',
          returnurl: return_url,
          paymentproductid: payment_product
        },
        payment: {
          amount: order.total.to_s.gsub('.', ''),
          currencycode: order.currency,
          countrycode: order.bill_address.country.iso,
          firstname: order.bill_address.firstname,
          surname: order.bill_address.lastname,
          languagecode: 'en',
          paymentproductid: payment_product,
          returnurl: return_url,
          hostedindicator: 1
        }
      )
    end

    private

    def endpoint_url
      preferred_test_mode ? TEST_URL : LIVE_URL
    end

    def global_collect
      @gc ||= GlobalCollectRequest.new(endpoint_url, preferred_merchant_id)
    end
  end
end
