class EachBankPaymentReceipt < PDFBase

  def initialize(from, to, project_name)
    super()

    from_date = (Date.parse(from) rescue nil)
    to_date = (Date.parse(to) rescue nil)
    report = Report::EachBankPaymentReceiptReport.new(self, from_date, to_date, project_name)
    report.show

    render_page_number
  end
end
