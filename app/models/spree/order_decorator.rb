Spree::Order.class_eval do
  delegate :country, :global_collect_firstname, :global_collect_surname,
           :global_collect_city, :zipcode, :state_text, :global_collect_street,
           to: :bill_address, allow_nil: true, prefix: true

  delegate :country, :global_collect_firstname, :global_collect_surname,
           :global_collect_city, :zipcode, :state_text, :global_collect_street,
           to: :ship_address, allow_nil: true, prefix: true

  def global_collect_number
    number.gsub(/[^0-9]/i, '')
  end

  def global_collect_total
    format_opts = { decimal_mark: '', thousands_separator: '', symbol: false }

    Spree::Money.new(total, format_opts).to_s
  end

  def address_iso(address_type)
    send("#{address_type}_address").try(:country).try(:iso)
  end

  # This is here because by default payment profiles enable the confirm step
  # but this is not needed with GobalCollect as the user has to confirm the
  # payment anyway.
  # Original method: https://github.com/spree/spree/blob/a1172606f27ee2e71f097bf301df9f99881ad2f5/core/app/models/spree/order.rb#L176
  def confirmation_required?
    Spree::Config[:always_include_confirm_step] || state == 'confirm'
  end
end
