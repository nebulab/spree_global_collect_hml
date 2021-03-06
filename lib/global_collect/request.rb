module GlobalCollect
  class Request
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
              meta: { merchantid: @merchant_id, version: '2.0' },
              params: params
            }
          }
        }, { key_converter: :upcase }
      )

      GlobalCollect::Response.new(post_xml(@endpoint, xml))
    end

    private


    # Quick test:
    # require 'openssl'
    # require 'net/https'
    #
    # url = URI.parse('https://ps.gcsip.nl/wdl/wdl')
    # http = Net::HTTP.new(url.host, url.port)
    # http.use_ssl = true
    # http.ssl_version = :TLSv1
    # http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    # http.post('/', '<test></test>', 'Content-Type' => 'text/xml')
    def post_xml(url_string, xml_string)
      url = URI.parse(url_string)
      http = Net::HTTP.new(url.host, url.port)
      if url.scheme == 'https'
        http.use_ssl = true
        http.ssl_version = :TLSv1
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        # http.ciphers = OpenSSL::SSL::SSLContext.new((:TLSv1)).ciphers.collect { |cipher_name, _cipher_version, _bits, _algorithm_bits| cipher_name }
        # http.ciphers = 'SRP-RSA-3DES-EDE-CBC-SHA'
      end

      response = http.post(url.path, xml_string, 'Content-Type' => 'text/xml')
      log('POST', url_string, xml_string, response.body)

      response.body
    end

    def log(method, url, request, response)
      request_log = Spree.t('global_collect.debug_request',
                            method: method, url: url, body: request)
      response_log = Spree.t('global_collect.debug_response', body: response)

      Rails.logger.info(request_log)
      Rails.logger.info(response_log)
    end
  end
end
