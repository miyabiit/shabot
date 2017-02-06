class AddCorporationCodeToPaymentHeaders < ActiveRecord::Migration
  def change
    add_column :payment_headers, :corporation_code, :integer
    add_index  :payment_headers, :corporation_code
  end
end
