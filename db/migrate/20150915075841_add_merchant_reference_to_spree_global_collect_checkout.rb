class AddMerchantReferenceToSpreeGlobalCollectCheckout < ActiveRecord::Migration
  def change
    add_column :spree_global_collect_checkouts, :merchant_reference, :string
  end
end
