Spree::Core::Engine.routes.draw do
  namespace :global_collect_hml do
    resource :credit_card_payment, only: :create
  end
end
