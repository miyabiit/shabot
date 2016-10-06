class Report::BankAccountBalanceReport < Report::ReportBase
  COL_WIDTHS = [15, 80, 120, 80, 225]

  def initialize(pdf, bank_account_balances)
    super(pdf)

    @pdf.line_width = 0.5
    @bank_account_balances = bank_account_balances
    @current_bank_balance = bank_account_balances.first
  end

  def show
    render_header

    @bank_account_balances.select(&:estimated_on?).each_with_index do |bank_account_balance, i|
      @current_bank_balance = bank_account_balance

      next_page if i != 0

      render_receipts
      br
      br
      render_payments
      br
    end
  end

  def render_header
    move_down 18
    render_create_date
    move_down 12
    render_title '口座別入出金明細'
    move_down 36
    render_bank_info
    br
    render_remains
    move_down 18
  end

  def render_create_date
    text_box "#{Date.today.strftime('%Y/%m/%d')}", size: 8, at: [0, cursor], width: bounds.width, height: 10, align: :right, valign: :center
  end

  def render_title(title)
    text_box title, size: 16, at: [0, cursor], width: bounds.width, height: 16, align: :center, valign: :center
  end

  def render_bank_info
    text_box @current_bank_balance.my_account&.bank_long_label, size: 8, at: [0, cursor], width: bounds.width, height: 10, align: :left, valign: :center
  end

  def render_remains
    col_sizes = [80, 120, 80]
    render_row [@current_bank_balance.based_on&.strftime('%Y/%m/%d'), '残高', @current_bank_balance.current_amount], col_sizes
    render_row [@current_bank_balance.estimated_on&.strftime('%Y/%m/%d'), '予想残高', @current_bank_balance.estimate_date_amount], col_sizes
  end

  def render_receipts
    render_table_header "入金明細", %W(入金日 入金元 金額 摘要・目的・効果)
    date_range = @current_bank_balance.estimated_on_date_range
    sum = 0
    @current_bank_balance.receipt_headers.joins(:account).where(receipt_on: date_range).order(:receipt_on, 'accounts.name').each do |receipt|
      amount = receipt.amount
      render_row ["", receipt.receipt_on&.strftime('%Y/%m/%d'), receipt.account&.name, amount, receipt.comment], COL_WIDTHS, padding_horizontal: 3
      sum += amount
    end
    hr
    render_row ["", "", "", sum, ""], COL_WIDTHS, padding_horizontal: 3
  end

  def render_payments
    render_table_header "出金明細", %W(支払日 取引先 金額 摘要・目的・効果), "＊: 実績"
    date_range = @current_bank_balance.estimated_on_date_range
    sum = 0
    @current_bank_balance.payment_headers.joins(:account).where(payable_on: date_range).order(:payable_on, 'accounts.name').each do |payment|
      amount = payment.total
      render_row [('＊' unless payment.planned?), payment.payable_on&.strftime('%Y/%m/%d'), payment.account&.name, amount, payment.comment], COL_WIDTHS, padding_horizontal: 3
      sum += amount
    end
    hr
    render_row ["", "", "", sum, ""], COL_WIDTHS, padding_horizontal: 3
  end

  def render_table_header(title, cols, comment=nil)
    if comment.present?
      float { text_box comment, size: 8, at: [0, cursor], width: bounds.width, height: 10, align: :right, valign: :bottom }
    end
    text_box title, size: 10, at: [0, cursor], width: bounds.width, height: 10, align: :left, valign: :center
    next_page if cursor <= 0
    move_down 14
    next_page if cursor <= 0
    hr
    render_row cols.unshift(''), COL_WIDTHS, padding_horizontal: 3
    hr
  end

end
