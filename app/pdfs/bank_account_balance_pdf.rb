# coding: utf-8

class BankAccountBalancePDF < PDFBase

  def initialize(bank_account_balances)
    super()

    report = Report::BankAccountBalanceReport.new(self, bank_account_balances)
    report.show

    render_page_number
  end
end
