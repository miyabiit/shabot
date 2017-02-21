class RemoveAccountIdFromMyAccounts < ActiveRecord::Migration
  def change
    remove_reference :my_accounts, :account, index: true
  end
end
