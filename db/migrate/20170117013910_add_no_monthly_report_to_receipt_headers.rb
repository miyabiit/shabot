class AddNoMonthlyReportToReceiptHeaders < ActiveRecord::Migration
  def change
    add_column :receipt_headers, :no_monthly_report, :boolean, default: false
  end
end
