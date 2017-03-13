class EachBankPaymentReceipt < PDFBase

  def initialize(from, to)
    super()

    from_date = (Date.parse(from) rescue nil)
    to_date = (Date.parse(to) rescue nil)
    report = Report::EachBankPaymentReceiptReport.new(self, from_date, to_date)
    report.show

    render_page_number
  end
end
