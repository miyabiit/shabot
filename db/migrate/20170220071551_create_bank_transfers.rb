class CreateBankTransfers < ActiveRecord::Migration
  def change
    create_table :bank_transfers do |t|
      t.references :receipt_header, index: true, foreign_key: true
      t.references :payment_header, index: true, foreign_key: true

      t.date :target_date
      t.integer :amount
      t.integer :src_my_account_id
      t.integer :dst_my_account_id
      t.integer :src_item_id
      t.integer :dst_item_id
      t.integer :project_id
      t.integer :user_id
      t.text :comment

      t.timestamps null: false
    end

    add_index :bank_transfers, :src_my_account_id
    add_index :bank_transfers, :dst_my_account_id
    add_index :bank_transfers, :src_item_id
    add_index :bank_transfers, :dst_item_id
    add_index :bank_transfers, :project_id
    add_index :bank_transfers, :user_id
  end
end
