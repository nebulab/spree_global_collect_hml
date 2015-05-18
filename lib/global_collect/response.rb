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
      when Hash  then hash_error(errors)
      when Array then array_errors(errors)
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

    def hash_error(errors)
      t_error(GlobalCollect::Constants::ERRORS[errors[:error][:code]])
    end

    def array_errors(errors)
      errors_text = errors.map do |error|
        GlobalCollect::Constants::ERRORS[error[:error][:code]]
      end.compact.join(', ')

      t_error(errors_text)
    end

    def t_error(error_text)
      if error_text.present?
        Spree.t('global_collect.payment_error', text: error_text)
      else
        Spree.t('global_collect.generic_payment_error')
      end
    end
  end
end
