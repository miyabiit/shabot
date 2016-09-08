class ProcessPaymentList < Prawn::Document

	def initialize(payments, title, from_date, to_date)
		super(
			:page_size => 'A4', 
			:page_layout => :portrait,
			:margin => 30,
			:left_margin => 60,
			:bottom_margin => 40
		)
    font Rails.root.to_s + '/' + "vendor/fonts/ipaexg.ttf"

    payments = payments.payable_on_is_not_null.eager_load(:project, :account).order("payment_headers.payable_on, payment_headers.slip_no")

    report = Report::ProcessPaymentReport.new(self, title, payments, from_date, to_date)
    report.show

    number_pages "<page> / <total>", at: [bounds.right - 100, bounds.top - 8], size: 8, width: 100, align: :right
	end
end