class AddNoMonthlyReportToPaymentHeaders < ActiveRecord::Migration
  def change
    add_column :payment_headers, :no_monthly_report, :boolean, default: false
  end
end
