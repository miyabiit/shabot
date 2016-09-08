class EachProjectPaymentList < Prawn::Document

  def initialize(payments)
    super(
      :page_size => 'A4', 
      :page_layout => :portrait,
      :margin => 30,
      :left_margin => 60,
      :bottom_margin => 40
    )
    font Rails.root.to_s + '/' + "vendor/fonts/ipaexg.ttf"

    payments = payments.payable_on_is_not_null.eager_load(:project, :account).order("DATE_FORMAT(payment_headers.payable_on, '%Y%m'), projects.name, projects.category, payment_headers.payable_on, accounts.name")

    report = Report::EachDayProjectReport.new(self, '月別プロジェクト別出金予定・実績一覧', payments, -> (a) { a.project_id })
    report.show

    number_pages "<page> / <total>", at: [bounds.right - 100, bounds.top - 8], size: 8, width: 100, align: :right
  end
end
