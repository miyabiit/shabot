class CreateBankAccountBalancePer5days < ActiveRecord::Migration
  def change
    create_table :bank_account_balance_per5days do |t|
      t.references :bank_account_balance, index: true, foreign_key: true, null: false
      t.date :target_date
      t.integer :amount, limit: 8

      t.timestamps null: false
    end
  end
end
