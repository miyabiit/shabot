class AddProcessedToPaymentHeaders < ActiveRecord::Migration
  def change
    add_column :payment_headers, :processed, :boolean, default: false
    add_reference :payment_headers, :process_user, index: true
    add_column :payment_headers, :process_date, :date
  end
end
