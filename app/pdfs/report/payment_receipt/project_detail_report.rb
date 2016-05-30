class Report::PaymentReceipt::ProjectDetailReport < Report::PaymentReceiptReportBase
  COL_WIDTHS = [20, 60, 10, 100, 100, 105, 105]

  def initialize(project, summary, pdf)
    super(summary, pdf)
    @project = project
    @report_type = :receipt
  end

  def show
    render_header

    summaries_project_by_month = @summary.summaries_project_by_month(@project.id)
    @report_type = :receipt
    render_content summaries_project_by_month
    @report_type = :payment
    next_page
    render_content summaries_project_by_month
  end

  def render_content(summaries_project_by_month)
    summaries_project_by_month.select{|r| @report_type == :receipt ? (r.receipt != 0) : (r.payment != 0)}
                              .each_with_index do |month_record, month_i|
      next_page unless month_i == 0
      month_record.children.select{|day_idx, r| @report_type == :receipt ? (r.receipt != 0) : (r.payment != 0)}
                           .each_with_index do |(day_idx, day10_record), day10_i|
        render_detail day10_record, (day10_i == 0)
      end
      render_monthly_summary month_record
    end
  end

  def render_detail(day10_record, show_month=false)
    details = case @report_type
              when :receipt
                ReceiptHeader.joins('LEFT OUTER JOIN accounts ON accounts.id = receipt_headers.account_id')
                             .joins('LEFT OUTER JOIN items ON items.id = receipt_headers.item_id')
                             .receipt_on_is_not_null.where(project_id: @project, receipt_on: day10_record.date_range)
                             .order('receipt_headers.receipt_on, receipt_headers.account_id, receipt_headers.item_id, receipt_headers.id')
                             .pluck('receipt_headers.account_id, receipt_headers.item_id, receipt_headers.id, NULL, receipt_headers.receipt_on, accounts.name, items.name, receipt_headers.amount')
              when :payment
                PaymentHeader.joins(:payment_parts)
                             .joins('LEFT OUTER JOIN accounts ON accounts.id = payment_headers.account_id')
                             .joins('LEFT OUTER JOIN items ON items.id = payment_parts.item_id')
                             .payable_on_is_not_null.where(project_id: @project, payable_on: day10_record.date_range)
                             .order('payment_headers.payable_on, payment_headers.account_id, payment_parts.item_id, payment_headers.id')
                             .pluck('payment_headers.account_id, payment_parts.item_id, payment_headers.id, payment_headers.planned, payment_headers.payable_on, accounts.name, items.name, payment_parts.amount')
              end
    return if details.empty?
    month_label = (show_month ? "#{day10_record.date_range.begin.month}月" : '')
    details.each_with_index do |detail, idx|
      not_planned_label = (@report_type == :receipt || detail[3]) ? '' : '＊'
      render_row [(idx == 0 ? month_label : ''), (idx == 0 ? day10_record.date_range_label : ''), not_planned_label] + detail.drop(4), COL_WIDTHS
    end
    hline COL_WIDTHS.take(2).inject(:+), bounds.right
    render_row ['', '', '', '', '', '', (@report_type == :receipt ? day10_record.receipt : day10_record.payment)], COL_WIDTHS
    br
  end

  def render_monthly_summary(month_record)
    hline COL_WIDTHS[0], bounds.right
    render_row ['', "#{month_record.date_range.begin.month}月計", '', '', '', '', (@report_type == :receipt ? month_record.receipt : month_record.payment)], COL_WIDTHS
  end

  def render_header
    br
    br
    render_title 'プロジェクト別入出金レポート（明細）'
    br
    br
    render_project_name(@project)
    render_target_dates
    br
    render_currency_unit
    render_detail_category category_name
    br
    br
    hr
    render_row column_names, COL_WIDTHS
    hr
  end

  def category_name
    case @report_type
    when :receipt
      '（入金）'
    when :payment
      '（出金）'
    end
  end

  def column_names
    case @report_type
    when :receipt
      ['', '', '', '入金日', '入金元', '費目', '金額']
    when :payment
      ['', '', '', '支払日', '取引先', '費目', '金額']
    end
  end
end
