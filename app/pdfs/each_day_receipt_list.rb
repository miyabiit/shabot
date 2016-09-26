class EachDayReceiptList < Prawn::Document

  def initialize(receipts)
    super(
      :page_size => 'A4', 
      :page_layout => :portrait,
      :margin => 30,
      :left_margin => 60,
      :bottom_margin => 40
    )
    font Rails.root.to_s + '/' + "vendor/fonts/ipaexg.ttf"

    receipts = receipts.receipt_on_is_not_null.eager_load(:project, :account).order("receipt_headers.receipt_on, projects.name, projects.category, accounts.name")

    report = Report::EachDayProjectReceiptReport.new(self, '月別入金日別入金予定一覧', receipts, -> (a) { a.receipt_on })
    report.show

    number_pages "<page> / <total>", at: [bounds.right - 100, bounds.top - 8], size: 8, width: 100, align: :right
  end
end
