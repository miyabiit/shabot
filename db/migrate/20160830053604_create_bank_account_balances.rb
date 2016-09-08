class CreateBankAccountBalances < ActiveRecord::Migration
  def self.up
    create_table :bank_account_balances do |t|
      t.references :my_account
      t.integer    :current_amount       , limit: 8
      t.date       :estimated_on
      t.integer    :current_month_amount , limit: 8
      t.integer    :two_month_amount     , limit: 8
      t.integer    :three_month_amount   , limit: 8
      
      t.timestamps
    end
  end

  def self.down
    drop_table :bank_account_balances
  end
end
