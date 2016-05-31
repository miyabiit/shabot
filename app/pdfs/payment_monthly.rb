class PaymentMonthly < Prawn::Document

  def initialize(payment_headers)
    super(
      :page_size => 'A4',
      :page_layout => :portrait,
      :margin => 30,
      :left_margin => 60,
      :bottom_margin => 40
    )

    @payments = payment_headers
    font Rails.root.to_s + '/' + "vendor/fonts/ipaexg.ttf"
    stroke_axis
  end
end
