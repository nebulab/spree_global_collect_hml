module Spree
  class GlobalCollectRequest
    def initialize(endpoint, merchant_id)
      @endpoint = endpoint
      @merchant_id = merchant_id
    end

    def call(action, params)
      xml = Gyoku.xml(
        {
          xml: {
            request: {
              action: action.to_s.upcase,
              meta: { merchantid: @merchant_id },
              params: params
            }
          }
        }, { key_converter: :upcase }
      )

      GlobalCollectResponse.new(post_xml(@endpoint, xml))
    end

    private

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
