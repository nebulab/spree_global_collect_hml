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
      response_field.present? && response_field[:result] == 'OK'
    rescue
      false
    end

    def paid?
      success? && response_field[:row][:statusid].to_i >= 80
    rescue
      false
    end

    private

    def response_field
      @parsed_xml[:xml][:request][:response]
    rescue
      nil
    end
  end
end
