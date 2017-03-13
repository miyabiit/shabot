class AddPlannedToReceiptHeaders < ActiveRecord::Migration
  def change
    add_column :receipt_headers, :planned, :boolean, default: true
  end
end
