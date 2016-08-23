class EachDayPaymentList < Prawn::Document

	def initialize(payments)
		super(
			:page_size => 'A4', 
			:page_layout => :portrait,
			:margin => 30,
			:left_margin => 60,
			:bottom_margin => 40
		)
    font Rails.root.to_s + '/' + "vendor/fonts/ipaexg.ttf"

    payments = payments.payable_on_is_not_null.eager_load(:project, :account).order("payment_headers.payable_on, projects.name, projects.category, accounts.name")

    report = Report::EachDayProjectReport.new(self, '月別支払日別出金予定・実績一覧', payments, -> (a) { a.payable_on })
    report.show

    number_pages "<page> / <total>", at: [bounds.right - 100, bounds.top - 8], size: 8, width: 100, align: :right
	end
end