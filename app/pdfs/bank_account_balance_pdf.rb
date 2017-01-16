# coding: utf-8

class BankAccountBalancePDF < PDFBase

  def initialize(bank_account_balances)
    super()

    summary_report = Report::BankAccountBalanceSummaryReport.new(self, bank_account_balances)
    summary_report.show

    start_new_page

    report = Report::BankAccountBalanceReport.new(self, bank_account_balances)
    report.show

    render_page_number
  end
end
