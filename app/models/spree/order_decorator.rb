Spree::Order.class_eval do
  delegate :country, :global_collect_firstname, :lastname, :zipcode,
           :state_text, :city, :global_collect_street,
           to: :bill_address, allow_nil: true, prefix: true

  delegate :country, :global_collect_firstname, :lastname, :zipcode,
           :state_text, :city, :global_collect_street,
           to: :ship_address, allow_nil: true, prefix: true

  def global_collect_number
    number.gsub(/[^0-9]/i, '')
  end

  def global_collect_total
    total.to_s.gsub('.', '')
  end

  def address_iso(address_type)
    send("#{address_type}_address").try(:country).try(:iso)
  end
end
