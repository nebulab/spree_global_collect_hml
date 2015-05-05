class ChangePaymentReferenceTypeOnSpreeGlobalCollectCheckout < ActiveRecord::Migration
  def change
    change_column :spree_global_collect_checkouts, :payment_reference, :string
  end
end
