class AddOrderDetailsToSpreeGlobalCollectCheckout < ActiveRecord::Migration
  def change
    add_column :spree_global_collect_checkouts, :effort_id, :integer
    add_column :spree_global_collect_checkouts, :attempt_id, :integer
    add_column :spree_global_collect_checkouts, :payment_method_id, :integer
    add_column :spree_global_collect_checkouts, :payment_reference, :integer
  end
end
