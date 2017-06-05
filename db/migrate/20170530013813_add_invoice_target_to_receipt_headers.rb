class AddInvoiceTargetToReceiptHeaders < ActiveRecord::Migration
  def change
    add_column :receipt_headers, :invoice_target, :boolean, default: false
  end
end
