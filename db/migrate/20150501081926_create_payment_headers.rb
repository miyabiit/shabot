class CreatePaymentHeaders < ActiveRecord::Migration
  def self.up
    create_table :payment_headers do |t|
      t.integer :user_id
      t.integer :account_id
      t.date :payable_on
      t.integer :project_id
      
      t.timestamps
    end
  end

  def self.down
    drop_table :payment_headers
  end
end
