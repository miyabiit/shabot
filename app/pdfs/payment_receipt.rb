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
    all_project_report = Report::PaymentReceipt::AllProjectReport.new(summary, self)
    all_project_report.show
    Project.all.order(:id).each_with_index do |project, project_i|
      start_new_page
      project_report = Report::PaymentReceipt::ProjectReport.new(project, summary, self)
      project_report.show

      start_new_page
      project_detail_report = Report::PaymentReceipt::ProjectDetailReport.new(project, summary, self)
      project_detail_report.show
    end

    number_pages "<page> / <total>", at: [bounds.right - 100, bounds.top - 8], size: 8, width: 100, align: :right
  end
end
