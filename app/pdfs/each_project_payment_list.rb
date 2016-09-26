class EachProjectPaymentList < PDFBase

  def initialize(payments)
    super()

    payments = payments.payable_on_is_not_null.eager_load(:project, :account).order("DATE_FORMAT(payment_headers.payable_on, '%Y%m'), projects.name, projects.category, payment_headers.payable_on, accounts.name")

    report = Report::EachDayProjectPaymentReport.new(self, '月別プロジェクト別出金予定・実績一覧', payments, -> (a) { a.project_id })
    report.show

    render_page_number
  end
end
