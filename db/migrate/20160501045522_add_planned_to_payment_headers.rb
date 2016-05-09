class AddPlannedToPaymentHeaders < ActiveRecord::Migration
  def change
    add_column :payment_headers, :planned, :boolean, default: false
  end
end
