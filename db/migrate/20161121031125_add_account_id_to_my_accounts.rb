class AddAccountIdToMyAccounts < ActiveRecord::Migration
  def change
    add_reference :my_accounts, :account, index: true
  end
end
