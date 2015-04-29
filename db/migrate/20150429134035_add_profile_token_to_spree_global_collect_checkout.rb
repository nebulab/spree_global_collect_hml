class AddProfileTokenToSpreeGlobalCollectCheckout < ActiveRecord::Migration
  def change
    add_column :spree_global_collect_checkouts, :profile_token, :string
  end
end
