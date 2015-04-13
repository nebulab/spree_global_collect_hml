module Spree
  class GlobalCollectResponse
    def initialize(raw_xml)
      parser = Nori.new(convert_tags_to: ->(tag) { tag.downcase.to_sym })

      @raw_xml = raw_xml
      @parsed_xml = parser.parse(@raw_xml)
    end

    def [](key)
      response_field[:row][key]
    rescue
      nil
    end

    def success?
      response_field.present? &&
        response_field[:result] == 'OK' &&
        response_field[:row][:errornumber].nil?
    rescue
      false
    end

    def paid?
      success? && response_field[:row][:statusid].to_i >= 800
    rescue
      false
    end

    def error
      response_field[:row][:errormessage]
    rescue
      nil
    end

    private

    def response_field
      @parsed_xml[:xml][:request][:response]
    rescue
      nil
    end
  end
end
