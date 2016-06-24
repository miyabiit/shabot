class AddFeeWhoPaidToPaymentHeaders < ActiveRecord::Migration
  def change
    add_column :payment_headers, :fee_who_paid, :string
    remove_column :accounts, :fee_who_paid
  end
end
