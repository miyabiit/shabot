class AddBasedOnToBankAccountBalances < ActiveRecord::Migration
  def change
    add_column :bank_account_balances, :based_on, :date
  end
end
