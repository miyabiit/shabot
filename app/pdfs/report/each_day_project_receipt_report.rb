class Report::EachDayProjectReceiptReport < Report::ReportBase
  COL_WIDTHS = [25, 15, 55, 100, 55, 100, 85, 70]

  def initialize(pdf, title, receipts, break_by)
    super(pdf)

    @title = title
    @receipts = receipts
    @current_month = @receipts.first&.receipt_on&.beginning_of_month
    @break_by = break_by 
    
    @pdf.line_width = 0.5
  end

  def show
    render_header

    month_amount = 0
    sub_amount = 0
    prev_receipt = nil
    line_no = 1
    @receipts.each do |receipt|
      if prev_receipt
        if @break_by.call(prev_receipt) != @break_by.call(receipt)
          render_amount(sub_amount)
          br
          sub_amount = 0
        end
      end

      month = receipt.receipt_on&.beginning_of_month
      if month && month != @current_month
        render_amount(month_amount)
        @current_month = month
        month_amount = 0
        sub_amount = 0
        next_page
      end
      amount = receipt.amount
      render_row [
        line_no.to_s,
        receipt.monthly_data ? '◯' : '',
        receipt.receipt_on,
        receipt.project&.name,
        receipt.project&.category,
        receipt.account&.name,
        amount,
        receipt.id,
      ], COL_WIDTHS, padding_horizontal: 3

      sub_amount += amount
      month_amount += amount
      prev_receipt = receipt
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
    float { text_box '◯: 定例', size: 8, at: [0, cursor], width: bounds.width, height: 10, align: :right, valign: :bottom }
    render_target_date
    @pdf.move_down 16
    hr
    render_row ['No.', '', '入金予定日', 'PROJECT', '', '入金元', '金額', '伝票番号'], COL_WIDTHS, padding_horizontal: 3
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
