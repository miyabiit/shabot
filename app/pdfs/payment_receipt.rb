class PaymentReceipt < PDFBase

  def initialize(from, to, project_name)
    super()

    summary = PaymentReceiptSummary.new(from, to, project_name)
    all_project_report = Report::PaymentReceipt::AllProjectReport.new(summary, self)
    all_project_report.show
    Project.not_deleted.order(:id).each_with_index do |project, project_i|
      start_new_page
      project_report = Report::PaymentReceipt::ProjectReport.new(project, summary, self)
      project_report.show

      start_new_page
      project_detail_report = Report::PaymentReceipt::ProjectDetailReport.new(project, summary, self)
      project_detail_report.show
    end

    render_page_number
  end
end
