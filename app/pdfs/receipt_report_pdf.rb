# coding: utf-8

class ReceiptReportPDF < Prawn::Document

  def initialize(receipt_header)
    super(
      :page_size => 'A4', 
      :page_layout => :portrait,
      :margin => 30,
      :left_margin => 60,
      :bottom_margin => 40
    )

    font Rails.root.to_s + '/' + "vendor/fonts/ipaexg.ttf"

    report = Report::ReceiptReport.new(self, receipt_header)
    report.show
  end
end
