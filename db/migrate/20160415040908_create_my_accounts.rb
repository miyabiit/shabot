class CreateMyAccounts < ActiveRecord::Migration
  def self.up
    create_table :my_accounts do |t|
      t.string :bank
      t.string :bank_branch
      t.string :category
      t.string :ac_no
      
      t.timestamps
    end
  end

  def self.down
    drop_table :my_accounts
  end
end
