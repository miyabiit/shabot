class AddCorporationCodeToReceiptHeaders < ActiveRecord::Migration
  def change
    add_column :receipt_headers, :corporation_code, :integer
    add_index  :receipt_headers, :corporation_code
  end
end
