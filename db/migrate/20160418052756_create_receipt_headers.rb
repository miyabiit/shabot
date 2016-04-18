class CreateReceiptHeaders < ActiveRecord::Migration
  def self.up
    create_table :receipt_headers do |t|
      t.references :user, index: true
      t.references :account, index: true
      t.date :receipt_on
      t.references :project
      t.text :comment
      t.references :item, index: true
      t.integer :amount
      t.references :my_account, index: true
      
      t.timestamps
    end
  end

  def self.down
    drop_table :receipt_headers
  end
end
