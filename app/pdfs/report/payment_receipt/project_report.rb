class Report::PaymentReceipt::ProjectReport < Report::PaymentReceiptReportBase
  COL_WIDTHS = [20, 60, 105, 105, 105, 105]

  def initialize(project, summary, pdf)
    super(summary, pdf)
    @project = project
  end

  def show
    render_header

    @summary.summaries_project_by_year(@project.id).each_with_index do |year_record, year_i|
      next_page unless year_i == 0
      year_record.children.each_with_index do |(month, month_record), month_i|
        month_record.children.each_with_index do |(day_idx, day10_record), day10_i|
          render_10days_summary(day10_record, (day10_i == 0))
        end
        render_monthly_summary(month_record)
      end
      render_yearly_summary(year_record)
    end
  end

  def render_10days_summary(day10_record, show_month = false)
    render_row [(show_month ? "#{day10_record.date_range.begin.month}月" : ''), day10_record.date_range_label, day10_record.receipt, day10_record.payment, day10_record.balance, day10_record.flow], COL_WIDTHS
  end

  def render_monthly_summary(month_record)
    hline COL_WIDTHS[0], bounds.right
    render_row ['', "#{month_record.date_range.begin.month}月計", month_record.receipt, month_record.payment, month_record.balance, month_record.flow], COL_WIDTHS
    br
    hr
  end

  def render_yearly_summary(year_record)
    render_row ['', "#{year_record.date_range.begin.year}年計", year_record.receipt, year_record.payment, year_record.balance, year_record.flow], COL_WIDTHS
  end

  def render_header
    br
    br
    render_title 'プロジェクト別入出金レポート（サマリ）'
    br
    br
    render_project_name(@project)
    render_target_dates
    br
    render_currency_unit
    br
    br
    hr
    render_row ['', '', '入金', '出金', '収支', 'キャッシュフロー'], COL_WIDTHS
    hr
  end

end
