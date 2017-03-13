class EachProjectReceiptList < PDFBase

  def initialize(receipts)
    super()

    receipts = receipts.receipt_on_is_not_null.eager_load(:project, :account).order("DATE_FORMAT(receipt_headers.receipt_on, '%Y%m'), projects.name, projects.category, receipt_headers.receipt_on, accounts.name")

    report = Report::EachDayProjectReceiptReport.new(self, '月別プロジェクト別入金予定・実績一覧', receipts, -> (a) { a.project_id })
    report.show

    render_page_number
  end
end
