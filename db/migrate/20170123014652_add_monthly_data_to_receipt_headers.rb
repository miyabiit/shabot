class AddMonthlyDataToReceiptHeaders < ActiveRecord::Migration
  def change
    add_column :receipt_headers, :monthly_data, :boolean, default: false
  end
end
