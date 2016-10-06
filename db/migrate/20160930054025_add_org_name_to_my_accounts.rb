class AddOrgNameToMyAccounts < ActiveRecord::Migration
  def change
    add_column :my_accounts, :org_name, :string
  end
end
