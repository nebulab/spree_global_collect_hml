class AddSpreeOrderIdToSpreeGlobalCollectCheckout < ActiveRecord::Migration
  def change
    add_column :spree_global_collect_checkouts, :order_id, :integer
  end
end
