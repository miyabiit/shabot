class ChangeIntegerLimitForAmountColumns < ActiveRecord::Migration
  def up
    %i(bank_transfers payment_parts receipt_headers).each do |table_name|
      change_column table_name, :amount, :integer, limit: 8
    end
  end

  def down
    %i(bank_transfers payment_parts receipt_headers).each do |table_name|
      change_column table_name, :amount, :integer, limit: 4
    end
  end
end
