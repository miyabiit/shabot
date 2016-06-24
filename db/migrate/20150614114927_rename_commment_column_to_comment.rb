class RenameCommmentColumnToComment < ActiveRecord::Migration
  def change
    rename_column :payment_headers, :commment, :comment
  end
end
