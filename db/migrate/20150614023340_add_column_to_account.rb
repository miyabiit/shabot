class AddColumnToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :fee_who_paid, :string
    change_column :accounts, :ac_no, :string
  end
end
