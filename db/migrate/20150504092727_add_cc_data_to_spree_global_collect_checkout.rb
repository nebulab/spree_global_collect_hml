class AddCcDataToSpreeGlobalCollectCheckout < ActiveRecord::Migration
  def change
    add_column :spree_global_collect_checkouts, :cc_last_four_digits, :string
    add_column :spree_global_collect_checkouts, :expiry_date, :date
  end
end
