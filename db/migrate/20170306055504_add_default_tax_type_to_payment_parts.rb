class AddDefaultTaxTypeToPaymentParts < ActiveRecord::Migration
  def change
    change_column_default :payment_parts, :tax_type, 'ex'
  end
end
