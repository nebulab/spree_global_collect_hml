module Spree
  class GlobalCollectResponse
    def initialize(raw_xml)
      parser = Nori.new(convert_tags_to: ->(tag) { tag.downcase.to_sym })

      @raw_xml = raw_xml
      @parsed_xml = parser.parse(@raw_xml)
    end

    def [](key)
      response_field[response_type][key]
    rescue
      nil
    end

    def to_s
      @parsed_xml.to_s
    end

    def valid?
      response_field.present? &&
        response_field[:result] == 'OK' &&
        response_field[:row][:errornumber].nil?
    rescue
      false
    end

    def success?
      valid? && response_field[:row][:statusid].to_i >= 600
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

    def response_type
      return :row    if response_field.try(:has_key?, :row)
      return :status if response_field.try(:has_key?, :status)
    end
  end
end
