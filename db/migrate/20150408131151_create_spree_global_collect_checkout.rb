class CreateSpreeGlobalCollectCheckout < ActiveRecord::Migration
  def change
    create_table :spree_global_collect_checkouts do |t|
      t.string :order_number
    end
  end
end
