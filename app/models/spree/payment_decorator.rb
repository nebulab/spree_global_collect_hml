Spree::Payment.class_eval do
  def global_collect_amount
    Spree::Money.new(amount_without_decimals).cents
  end

  private

  def amount_without_decimals
    Spree::Config[:hide_cents] ? amount.floor : amount
  end
end
