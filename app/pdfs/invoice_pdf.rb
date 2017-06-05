# coding: utf-8

class InvoicePDF < PDFBase

  def initialize(receipt_header)
    super()

    report = Report::InvoiceReport.new(self, receipt_header)
    report.show
  end
end
