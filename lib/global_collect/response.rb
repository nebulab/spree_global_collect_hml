module GlobalCollect
  class Response
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
      response_field.present? && response_field[:result] == 'OK'
    rescue
      false
    end

    def success?
      valid? && response_field[response_type][:statusid].to_i >= 525
    rescue
      false
    end

    def error
      errors = response_field[response_type][:errors]

      case errors
      when Hash  then GlobalCollect::Constants::ERRORS[errors[:error][:code]]
      when Array then GlobalCollect::Constants::ERRORS[errors.first[:error][:code]]
      end
    rescue
      nil
    end

    def message
      @raw_xml.to_s
    end

    def avs_result
      result = response_field[response_type][:avsresult]

      { code: result == '0' ? nil : result }
    end

    def cvv_result
      result = response_field[response_type][:cvvresult]

      result == '0' ? nil : result
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
