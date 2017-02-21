# coding: utf-8

class BankTransferPDF < PDFBase

  def initialize(bank_transfer_report)
    super()

    Report::BankTransferReport.new(self, bank_transfer_report, '(移動元保管用)').show
    start_new_page
    Report::BankTransferReport.new(self, bank_transfer_report, '(移動先保管用)').show
  end
end
