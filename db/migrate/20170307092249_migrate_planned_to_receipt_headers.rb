class MigratePlannedToReceiptHeaders < ActiveRecord::Migration
  def up
    execute "UPDATE receipt_headers SET planned = FALSE"
  end

  def down
  end
end
