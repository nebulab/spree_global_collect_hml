Spree::Core::Engine.routes.draw do
  resource :global_collect_hml_payment, only: :create

  get :confirm,  to: 'global_collect_hml_payments#confirm',
                 as: :global_collect_hml_payments_confirm
  get :complete, to: 'global_collect_hml_payments#complete',
                 as: :global_collect_hml_payments_complete
end
