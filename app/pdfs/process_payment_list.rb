class ProcessPaymentList < PDFBase

  def initialize(payments, title, from_date, to_date)
    super()

    payments = payments.payable_on_is_not_null.eager_load(:project, :account).order("payment_headers.payable_on, payment_headers.slip_no")

    report = Report::ProcessPaymentReport.new(self, title, payments, from_date, to_date)
    report.show

    render_page_number
  end
end
