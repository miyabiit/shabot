class ChangeColumnToAmount < ActiveRecord::Migration
  def change
    change_column :payment_parts, :amount, :integer
  end
end
