Spree::Core::Engine.routes.draw do
  namespace :global_collect_hml do
    resource :credit_card_payment, only: :create
    get :confirm, to: 'credit_card_payment#confirm', as: :credit_card_payments_confirm
  end
end
