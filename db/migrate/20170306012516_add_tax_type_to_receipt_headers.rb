class AddTaxTypeToReceiptHeaders < ActiveRecord::Migration
  def change
    add_column :receipt_headers, :tax_type, :string
  end
end
