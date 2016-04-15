class AddMyAccountToPaymentHeaders < ActiveRecord::Migration
  def change
    add_reference :payment_headers, :my_account, index: true
  end
end
