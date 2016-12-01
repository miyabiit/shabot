class AddPaymentTypeToPaymentHeaders < ActiveRecord::Migration
  def change
    add_column :payment_headers, :payment_type, :string
  end
end
