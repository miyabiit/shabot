class AddTaxTypeToPaymentParts < ActiveRecord::Migration
  def change
    add_column :payment_parts, :tax_type, :string
  end
end
