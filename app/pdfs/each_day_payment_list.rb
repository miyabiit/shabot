class EachDayPaymentList < PDFBase

  def initialize(payments)
    super()

    payments = payments.payable_on_is_not_null.eager_load(:project, :account).order("payment_headers.payable_on, projects.name, projects.category, accounts.name")

    report = Report::EachDayProjectPaymentReport.new(self, '月別支払日別出金予定・実績一覧', payments, -> (a) { a.payable_on })
    report.show

    render_page_number
  end
end
