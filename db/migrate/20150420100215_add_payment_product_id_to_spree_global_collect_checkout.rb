class AddPaymentProductIdToSpreeGlobalCollectCheckout < ActiveRecord::Migration
  def change
    add_column :spree_global_collect_checkouts, :payment_product_id, :integer
  end
end
