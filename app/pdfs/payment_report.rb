class PaymentReport < Prawn::Document

	def initialize(payment_header)
		super(
			:page_size => 'A4', 
			:page_layout => :portrait,
			:margin => 30,
			:left_margin => 60,
			:bottom_margin => 40
		)

		@payment = payment_header
		font Rails.root.to_s + '/' + "vendor/fonts/ipaexg.ttf"
		stroke_axis
		
		# lines
		line_width = 0.5
		dash(1)
		stroke do
			rectangle [0, 750], 510, 750
		end

		# stamp fields
		self.line_width = 0.5
		undash
		stroke do
			horizontal_line 310, 510, :at => 750
			horizontal_line 310, 510, :at => 710
			6.times do |n|
				vertical_line 750, 710, :at => (310 + 40 * n)
			end
		end

		# tables
		self.line_width = 0.5
		undash
		stroke do
			13.times do |n|
				horizontal_line 0, 510, :at => 700 - (25 * n)
			end
		end
		self.line_width = 1
		stroke do
			horizontal_line 0, 510, :at => 500
			horizontal_line 0, 510, :at => 525
		end
		self.line_width = 0.5
		stroke do
			vertical_line 700, 400, :at => 0
			vertical_line 700, 400, :at => 70
			vertical_line 700, 400, :at => 240 
			vertical_line 700, 400, :at => 310
			vertical_line 700, 400, :at => 510
			rectangle [0,398], 510, 100
		end

		# label
		fill_color "0000ff"
		draw_text @payment.org_name , :size => 12, :at => [5,760]
		fill_color "000000"
		draw_text '作成:' + @payment.created_at.strftime("%Y/%m/%d") , :size => 10, :at => [420,760]
		draw_text "支払申請書", :size => 18, :at => [5,730]
		draw_text "No." + @payment.slip_no.to_s , :size => 12, :at => [5,710]

		cols = %w(個人コード 所属 勘定科目１ 勘定科目２ 勘定科目３ 勘定科目４ 勘定科目５ 支払日 振込先 事業名 予算区分 引落元)
		cols.each_with_index do |s, n|
			draw_text s, :size => 12, :at => [5,( (700 - 25 + 7) - (25 * n))]
		end
		cols = %w(申請者 支払先 金額 金額 金額 金額 金額 計 支店・口座 PROJECT 振込手数料 支店・口座)
		cols.each_with_index do |s, n|
			draw_text s, :size => 12, :at => [245,( (700 - 25 + 7) - (25 * n))]
		end
		draw_text '摘要・目的・効果', :size => 10, :at => [5,385]
		draw_text '(証憑等添付)', :size => 10, :at => [5,285]
		#text Account.find(@payment.account_id).name

		# value
		account = Account.find(@payment.account_id)
		# cols = %w(個人コード 所属 勘定科目１ 勘定科目２ 勘定科目３ 勘定科目４ 勘定科目５ 支払日 振込先 事業名 予算区分 引落元)
		draw_text Casein::AdminUser.find(@payment.user_id).member_code.to_s, :size => 12, :at => [100 ,( (700 - 25 + 7) - (25 * 0))]
		draw_text Casein::AdminUser.find(@payment.user_id).section.to_s, :size => 12, :at => [100 ,( (700 - 25 + 7) - (25 * 1))]
		@payment.payment_parts.each_with_index do |part, i|
			draw_text Item.find(part.item_id).name , :size => 12, :at => [100 ,( (700 - 25 + 7) - (25 * (i + 2)))]
		end
		draw_text @payment.payable_on.to_s, :size => 12, :at => [100 ,( (700 - 25 + 7) - (25 * 7))]
		draw_text account.bank, :size => 12, :at => [100 ,( (700 - 25 + 7) - (25 * 8))]
		draw_text Project.find(@payment.project_id).name, :size => 12, :at => [100 ,( (700 - 25 + 7) - (25 * 9))]
		draw_text @payment.budget_code, :size => 12, :at => [100 ,( (700 - 25 + 7) - (25 * 10))]
		draw_text @payment.my_bank_label, :size => 12, :at => [100 ,( (700 - 25 + 7) - (25 * 11))] # 引落元

		text_box @payment.comment, :size => 12, :at => [5 ,( (700 - 25) - (25 * 12))], :width => 500, :height => 100, :align => :left, :valign => :top

		# cols = %w(申請者 支払先 金額 金額 金額 金額 金額 計 支店・口座 PROJECT 振込手数料 支店・口座)
		draw_text Casein::AdminUser.find(@payment.user_id).name, :size => 12, :at => [330 ,( (700 - 25 + 7) - (25 * 0))]
		if account.name.length < 15
			draw_text account.name, :size => 12, :at => [330 ,( (700 - 25 + 7) - (25 * 1))]
		else
			text_box account.name,  :size => 10, :at => [330 , 700 - 25], :width => 150, :height => 25, :align => :right, :valign => :center
		end
		total = 0
		@payment.payment_parts.each_with_index do |part, i|
			text_box part.amount.to_i.to_s(:delimited), :size => 12, :at => [330 ,( 700 - (25 * (i + 2)))], :width => 150, :height => 25, :align => :right, :valign => :center
			total += part.amount
		end
		text_box total.to_i.to_s(:delimited), :size => 12, :at => [330 ,( (700 - 25) - (25 * 6))], :width => 150, :height => 25, :align => :right, :valign => :center
		draw_text account.bank_branch + " " + account.category + " " + account.ac_no.to_s, :size => 12, :at => [330 ,( (700 - 25 + 7) - (25 * 8))]
		draw_text Project.find(@payment.project_id).category, :size => 12, :at => [330 ,( (700 - 25 + 7) - (25 * 9))]
		draw_text @payment.fee_who_paid, :size => 12, :at => [330 ,( (700 - 25 + 7) - (25 * 10))]
		draw_text @payment.my_bank_branch_and_number_label, :size => 12, :at => [330 ,( (700 - 25 + 7) - (25 * 11))] # 支店・口座
	end
end
