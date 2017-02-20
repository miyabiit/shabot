# coding: utf-8

class BankTransferPDF < PDFBase

  def initialize(bank_transfer_report)
    super()

    summary_report = Report::BankTransferReport.new(self, bank_transfer_report)
    summary_report.show

    render_page_number
  end
end
