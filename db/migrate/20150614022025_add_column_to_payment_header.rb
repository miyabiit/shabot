class AddColumnToPaymentHeader < ActiveRecord::Migration
  def change
    add_column :payment_headers, :org_name, :string
    add_column :payment_headers, :slip_no, :string
    add_column :payment_headers, :commment, :text
    add_column :payment_headers, :budget_code, :string
  end
end
