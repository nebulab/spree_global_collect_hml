class AddSpreePaymentMethodIdToSpreeGlobalCollectCheckout < ActiveRecord::Migration
  def change
    rename_column :spree_global_collect_checkouts, :payment_method_id, :gc_payment_method_id
    add_column :spree_global_collect_checkouts, :payment_method_id, :integer
  end
end
