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

      if response && response[:result] == 'OK'
        Class.new do
          def success?; true; end
          def authorization; nil; end
        end.new
      else
        class << response
          def to_s
            errors.map(&:long_message).join(" ")
          end
        end
        response
      end
    end

    def get_orderstatus(order_number)
      xml = Gyoku.xml(
        { xml: { request: {
          action: 'GET_ORDERSTATUS',
          meta: { merchantid: preferred_merchant_id },
          params: {
            order: {
              orderid: order_number,
            }
          }
        }}}, { key_converter: :upcase })

      parse_xml_response(post_xml(endpoint_url, xml))
    end

    def insert_orderwithpayment(order, payment_product, return_url)
      xml = Gyoku.xml(
        { xml: { request: {
          action: 'INSERT_ORDERWITHPAYMENT',
          meta: { merchantid: preferred_merchant_id },
          params: {
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
          }
        }}}, { key_converter: :upcase })

      parse_xml_response(post_xml(endpoint_url, xml))
    end

    private

    def endpoint_url
      preferred_test_mode ? TEST_URL : LIVE_URL
    end

    def parse_xml_response(xml_string)
      parser = Nori.new(convert_tags_to: ->(tag) { tag.downcase.to_sym })

      parser.parse(xml_string)
        .try(:[], :xml).try(:[], :request).try(:[], :response)
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
