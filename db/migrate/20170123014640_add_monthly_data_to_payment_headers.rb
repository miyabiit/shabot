class AddMonthlyDataToPaymentHeaders < ActiveRecord::Migration
  def change
    add_column :payment_headers, :monthly_data, :boolean, default: false
  end
end
