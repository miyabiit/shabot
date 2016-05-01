class AddPlannedToPaymentHeaders < ActiveRecord::Migration
  def change
    add_column :payment_headers, :planned, :boolean, defalult: false
  end
end
