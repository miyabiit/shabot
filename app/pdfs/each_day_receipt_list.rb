class EachDayReceiptList < PDFBase

  def initialize(receipts)
    super()

    receipts = receipts.receipt_on_is_not_null.eager_load(:project, :account).order("receipt_headers.receipt_on, projects.name, projects.category, accounts.name")

    report = Report::EachDayProjectReceiptReport.new(self, '月別入金日別入金予定・実績一覧', receipts, -> (a) { a.receipt_on })
    report.show

    render_page_number
  end
end
