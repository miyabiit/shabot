class AddCommentToPaymentParts < ActiveRecord::Migration
  def change
    add_column :payment_parts, :comment, :text
  end
end
