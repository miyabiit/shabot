# coding: utf-8

class PaymentReportPDF < PDFBase

  A4_SIZE = [595.28, 841.89]
	
  # A4 -> 595.28 x 841.89
  # コンテンツの横x縦がちょうど510mmx750になるようマージン設定
  def initialize(payment_header)
    super(
      :margin => 30,
      :left_margin => 60,
      :right_margin => A4_SIZE[0] - 510 - 60,
      :top_margin => 50,
      :bottom_margin => A4_SIZE[1] - 750 - 50
    )
    report = Report::PaymentReport.new(self, payment_header)
    report.show
  end
end
