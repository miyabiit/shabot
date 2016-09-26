# coding: utf-8

class ReceiptReportPDF < PDFBase

  def initialize(receipt_header)
    super()

    report = Report::ReceiptReport.new(self, receipt_header)
    report.show
  end
end
