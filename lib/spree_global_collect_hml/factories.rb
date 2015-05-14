FactoryGirl.define do
  # Define your Spree extensions Factories within this file to enable applications, and other extensions to use and override them.
  #
  # Example adding this to your spec_helper will load these Factories for use:
  # require 'spree_global_collect_hml/factories'

  factory :global_collect_checkout, class: Spree::GlobalCollectCheckout do
    order_number 123456789
  end

  factory :global_collect_payment, class: Spree::Payment do
    amount 45.75
    association(:payment_method, factory: :global_collect_payment_method)
    association(:source, factory: :global_collect_checkout)
    order
    state 'checkout'
    response_code '12345'
  end

  factory :global_collect_payment_method, class: Spree::Gateway::GlobalCollectHml do
    name 'Global Collect'
    environment 'test'
  end
end
