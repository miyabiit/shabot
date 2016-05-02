class PaymentReceipt < Prawn::Document
  def initialize(from, to)
    super(
      :page_size => 'A4',
      :page_layout => :portrait,
      :margin => 30,
      :left_margin => 60,
      :bottom_margin => 40
    )
    font Rails.root.to_s + '/' + "vendor/fonts/ipaexg.ttf"

    summary = PaymentReceiptSummary.new(from, to)
    summary.fetch
    report = summary.get_all_project_report(self)
    report.show

    number_pages "<page> / <total>", at: [bounds.right - 100, bounds.top - 8], size: 8, width: 100, align: :right
  end
end
