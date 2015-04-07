module Spree
  class Gateway::GlobalCollectHml::CreditCard < Gateway
    TEST_URL = 'https://ps.gcsip.nl/wdl/wdl'
    LIVE_URL = 'https://ps.gcsip.com/wdl/wdl'

    preference :merchant_id, :string
    preference :test_mode, :boolean, default: false

    def method_type
      'global_collect_hml_credit_card'
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

    def purchase
      # TODO: implement... this needs to be called when Global Collect calls the
      #       application server back to notify everything is ok
    end

    def insert_orderwithpayment(order)
      xml = Gyoku.xml(
        { xml: { request: {
          action: 'INSERT_ORDERWITHPAYMENT',
          meta: { merchantid: preferred_merchant_id },
          params: {
            order: {
              orderid: order.number.gsub(/[^0-9]/i, ''),
              merchantreference: rand(Time.now.to_i).to_s.slice(0..29),
              amount: order.total.to_s.gsub('.', ''),
              currencycode: order.currency,
              countrycode: order.bill_address.country.iso,
              firstname: order.bill_address.firstname,
              surname: order.bill_address.lastname,
              languagecode: 'en',
              paymentproductid: 1
            },
            payment: {
              amount: order.total.to_s.gsub('.', ''),
              currencycode: order.currency,
              countrycode: order.bill_address.country.iso,
              firstname: order.bill_address.firstname,
              surname: order.bill_address.lastname,
              languagecode: 'en',
              paymentproductid: 1,
              hostedindicator: 1
            }
          }
        }}}, { key_converter: :upcase })

      parser = Nori.new(convert_tags_to: ->(tag) { tag.downcase.to_sym })
      parser.parse(post_xml(endpoint_url, xml))
    end

    private

    def endpoint_url
      preferred_test_mode ? TEST_URL : LIVE_URL
    end

    def post_xml(url_string, xml_string)
      url = URI.parse(url_string)
      http = Net::HTTP.new(url.host, url.port)
      if url.scheme == 'https'
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        http.ciphers = 'RC4-MD5'
      end

      response = http.post(url.path, xml_string, 'Content-Type' => 'text/xml')
      response.body
    end
  end
end
