Spree::Order.class_eval do
  def global_collect_number
    number.gsub(/[^0-9]/i, '')
  end

  def global_collect_total
    total.to_s.gsub('.', '')
  end
end
