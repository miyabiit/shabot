class AddDefaultTaxTypeToReceiptHeaders < ActiveRecord::Migration
  def change
    change_column_default :receipt_headers, :tax_type, 'ex'
  end
end
