class AddCorporationCodeToMyAccounts < ActiveRecord::Migration
  def change
    add_column :my_accounts, :corporation_code, :integer
    add_index  :my_accounts, :corporation_code
  end
end
