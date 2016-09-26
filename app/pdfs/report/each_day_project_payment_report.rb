class Report::EachDayProjectPaymentReport < Report::ReportBase
  COL_WIDTHS = [25, 15, 55, 100, 55, 115, 85, 70]

  def initialize(pdf, title, payments, break_by)
    super(pdf)

    @title = title
    @payments = payments
    @current_month = @payments.first&.payable_on&.beginning_of_month
    @break_by = break_by 
    
    @pdf.line_width = 0.5
  end

  def show
    render_header

    month_amount = 0
    sub_amount = 0
    prev_payment = nil
    line_no = 1
    @payments.each do |payment|
      if prev_payment
        if @break_by.call(prev_payment) != @break_by.call(payment)
          render_amount(sub_amount)
          br
          sub_amount = 0
        end
      end

      month = payment.payable_on&.beginning_of_month
      if month && month != @current_month
        render_amount(month_amount)
        @current_month = month
        month_amount = 0
        sub_amount = 0
        next_page
      end
      amount = payment.payment_parts.sum(:amount)
      render_row [
        line_no.to_s,
        payment.planned ? '' : '＊',
        payment.payable_on,
        payment.project&.name,
        payment.project&.category,
        payment.account&.name,
        amount,
        payment.slip_no,
      ], COL_WIDTHS, padding_horizontal: 3

      sub_amount += amount
      month_amount += amount
      prev_payment = payment
      line_no += 1
    end

    render_amount(sub_amount)
    br
    render_amount(month_amount)
  end

  def render_title(title)
    text_box title, size: 16, at: [0, cursor], width: bounds.width, height: 16, align: :center, valign: :center
  end

  def render_header
    br
    br
    render_title @title
    render_create_date
    br
    br
    float { text_box '＊: 実績', size: 8, at: [0, cursor], width: bounds.width, height: 10, align: :right, valign: :bottom }
    render_target_date
    @pdf.move_down 16
    hr
    render_row ['No.', '', '支払日', 'PROJECT', '', '取引先', '金額', '伝票番号'], COL_WIDTHS, padding_horizontal: 3
    hr
    br
  end

  def render_create_date
    text_box "作成: #{Date.today.strftime('%Y/%m/%d')}", size: 10, at: [0, cursor], width: bounds.width, height: 10, align: :right, valign: :center
  end

  def render_target_date
    text_box "#{@current_month&.strftime('%Y年 %m月')}", size: 10, at: [0, cursor], width: bounds.width, height: 10, align: :left, valign: :center
  end

  def render_amount(amount)
    hr
    render_row ['', '', '', '', '', '', amount, ''], COL_WIDTHS, padding_horizontal: 3
  end
end
