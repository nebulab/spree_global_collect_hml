Spree::Core::Engine.routes.draw do
  resource :global_collect_hml_payment, only: :create
  resource :global_collect_checkout, only: :update

  get 'global_collect_hml_payments/confirm',
      to: 'global_collect_hml_payments#confirm',
      as: :global_collect_hml_payments_confirm

  get 'global_collect_hml_payments/:order_id/complete',
      to: 'global_collect_hml_payments#complete',
      as: :global_collect_hml_payments_complete
end
