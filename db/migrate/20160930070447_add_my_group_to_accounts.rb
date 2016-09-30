class AddMyGroupToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :my_group, :boolean, default: false
  end
end
