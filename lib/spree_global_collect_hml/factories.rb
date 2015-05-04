FactoryGirl.define do
  # Define your Spree extensions Factories within this file to enable applications, and other extensions to use and override them.
  #
  # Example adding this to your spec_helper will load these Factories for use:
  # require 'spree_global_collect_hml/factories'

  factory :global_collect_checkout, class: Spree::GlobalCollectCheckout do
    order_number 123456789
  end
end
