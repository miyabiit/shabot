# coding: utf-8

class BankAccountBalancePDF < PDFBase

  def initialize(bank_account_balances)
    super(page_layout: :landscape)

    summary_report = Report::BankAccountBalanceSummaryReport.new(self, bank_account_balances)
    summary_report.show

    if BankAccountBalancePer5day.exists?
      start_new_page
      per5day_report = Report::BankAccountBalancePer5dayReport.new(self, bank_account_balances)
      per5day_report.show
    end

    render_page_number

    start_new_page(layout: :portrait)

    report = Report::BankAccountBalanceReport.new(self, bank_account_balances)
    report.show

    render_page_number
  end
end
