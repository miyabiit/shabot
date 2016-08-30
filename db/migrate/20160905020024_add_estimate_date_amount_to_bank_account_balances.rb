class AddEstimateDateAmountToBankAccountBalances < ActiveRecord::Migration
  def change
    add_column :bank_account_balances, :estimate_date_amount, :integer, limit: 8
  end
end
