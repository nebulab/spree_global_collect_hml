Spree::Core::Engine.routes.draw do
  resource :global_collect_hml_payment, only: :create

  get :confirm, to: 'global_collect_hml_payments#confirm',
                as: :global_collect_hml_payments_confirm
end
