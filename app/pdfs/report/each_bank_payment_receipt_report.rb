class Report::EachBankPaymentReceiptReport < Report::ReportBase
  COL_WIDTHS = [15, 80, 120, 80, 225]

  def initialize(pdf, from_date, to_date)
    super(pdf)

    @pdf.line_width = 0.5
    @from_date = from_date
    @to_date = to_date
    @date_range = ((@from_date || Date.new(1999, 1, 1))..(@to_date || Date.new(3000, 1, 1)))
    @my_accounts = MyAccount.not_deleted.corporation_code_order('asc').bank_name_order('asc')
    @receipt_headers = ReceiptHeader.left_join_accounts.left_join_projects.where(receipt_on: @date_range).order(:receipt_on, 'accounts.name')
    @payment_headers = PaymentHeader.left_join_accounts.left_join_projects.where(payable_on: @date_range).order(:payable_on, 'accounts.name')
    @current_my_account = @my_accounts.first
  end

  def show
    render_header

    @my_accounts.each_with_index do |account, i|
      @current_my_account = account

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
    render_target_dates
    move_down 36
  end

  def render_create_date
    text_box "#{Date.today.strftime('%Y/%m/%d')}", size: 8, at: [0, cursor], width: bounds.width, height: 10, align: :right, valign: :center
  end

  def render_title(title)
    text_box title, size: 16, at: [0, cursor], width: bounds.width, height: 16, align: :center, valign: :center
  end

  def render_bank_info
    text_box @current_my_account&.bank_long_label, size: 8, at: [0, cursor], width: bounds.width, height: 10, align: :left, valign: :center
  end

  def render_target_dates
    text_box "#{@from_date&.strftime('%Y/%m/%d')} 〜 #{@to_date&.strftime('%Y/%m/%d')}", size: 8, at: [0, cursor], width: bounds.width, height: 10, align: :left, valign: :center
  end

  def render_receipts
    render_table_header "入金明細", %W(入金日 入金元 金額 摘要・目的・効果)
    sum = 0
    @receipt_headers.with_my_account_id(@current_my_account.id).each do |receipt|
      amount = receipt.amount
      render_row ["", receipt.receipt_on&.strftime('%Y/%m/%d'), receipt.account&.name, amount, receipt.comment], COL_WIDTHS, padding_horizontal: 3
      sum += amount
    end
    hr
    render_row ["", "", "", sum, ""], COL_WIDTHS, padding_horizontal: 3
  end

  def render_payments
    render_table_header "出金明細", %W(支払日 取引先 金額 摘要・目的・効果), "＊: 実績"
    sum = 0
    @payment_headers.with_my_account_id(@current_my_account.id).each do |payment|
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
