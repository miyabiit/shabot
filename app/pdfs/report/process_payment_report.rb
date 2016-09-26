class Report::ProcessPaymentReport < Report::ReportBase
  COL_WIDTHS = [15, 45, 40, 90, 55, 60, 60, 65, 90]

  def initialize(pdf, title, payments, from_date = nil, to_date = nil)
    super(pdf)

    @title = title
    @payments = payments
    @pdf.line_width = 0.5
    @from_date = from_date
    @to_date = to_date 
  end

  def show
    render_header
    @payments.each do |payment|
      amount = payment.payment_parts.sum(:amount)
      render_row [
        payment.planned ? '' : '＊',
        payment.user&.name,
        payment.slip_no,
        payment.account&.name,
        payment.payable_on,
        amount,
        payment.project&.name,
        payment.project&.category,
        payment&.comment,
      ], COL_WIDTHS, padding_horizontal: 3
    end
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
    render_target_dates
    br
    @pdf.move_down 16
    text_box '＊: 実績', size: 8, at: [0, cursor], width: bounds.width, height: 8, align: :right
    br
    hr
    render_row ['', '作成者', '伝票No', '支払先', '支払日', '支払金額', 'プロジェクト', '', '摘要・目的・効果'], COL_WIDTHS, padding_horizontal: 3
    hr
    br
  end

  def render_create_date
    text_box "作成: #{Date.today.strftime('%Y/%m/%d')}", size: 10, at: [0, cursor], width: bounds.width, height: 10, align: :right, valign: :center
  end

  def render_target_dates
    text_box "期間: #{@from_date} 〜 #{@to_date}", size: 10, at: [0, cursor], width: bounds.width, height: 10, align: :right, valign: :center
  end

end
