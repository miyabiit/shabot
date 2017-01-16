class Report::BankAccountBalanceSummaryReport < Report::ReportBase
  COL_WIDTHS = [120, 240, 75, 75, 75, 75, 75, 75]

  def initialize(pdf, bank_account_balances)
    super(pdf)

    @pdf.line_width = 0.5
    @bank_account_balances = bank_account_balances
    @current_bank_balance = bank_account_balances.first
  end

  def show
    render_header

    move_down 3
    next_page if cursor <= 0

    @bank_account_balances.each do |bank_account_balance|
      render_table_row(bank_account_balance)
      move_down 3
      next_page if cursor <= 0
    end

    render_total_row
  end

  def render_header
    move_down 18
    render_create_date
    move_down 12
    render_title '口座別資金繰残高Simulator'
    move_down 36
    render_dates
    move_down 10
    render_table_header
  end

  def render_create_date
    text_box "#{Date.today.strftime('%Y/%m/%d')}", size: 8, at: [0, cursor], width: bounds.width, height: 10, align: :right, valign: :center
  end

  def render_title(title)
    text_box title, size: 16, at: [0, cursor], width: bounds.width, height: 16, align: :center, valign: :center
  end

  def render_dates
    col_sizes = [80, 80]
    render_row ['起算日', @current_bank_balance.based_on&.strftime('%Y/%m/%d')], col_sizes
    render_row ['推定日', @current_bank_balance.estimated_on&.strftime('%Y/%m/%d')], col_sizes
  end

  def render_table_header
    hr
    render_row %W(法人名 口座 前日繰越残高 推定日 当月末 翌月末 翌々月末), COL_WIDTHS, padding_horizontal: 3
    hr
  end

  def render_table_row(bank_account_balance)
    render_row [
      bank_account_balance.my_account&.org_name,
      bank_account_balance.my_account&.bank_long_label,
      bank_account_balance.current_amount,
      bank_account_balance.estimate_date_amount,
      bank_account_balance.current_month_amount,
      bank_account_balance.two_month_amount,
      bank_account_balance.three_month_amount,
    ], COL_WIDTHS, padding_horizontal: 3
  end

  def render_total_row
    hr
    render_row [
      "合計",
      "",
      *(
        %i(current_amount estimate_date_amount current_month_amount two_month_amount three_month_amount).map {|attr_name|
          @bank_account_balances.map(&attr_name).compact.sum
        }
      )
    ], COL_WIDTHS, padding_horizontal: 3
  end

end
