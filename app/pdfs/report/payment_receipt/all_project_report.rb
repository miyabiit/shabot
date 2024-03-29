class Report::PaymentReceipt::AllProjectReport < Report::PaymentReceiptReportBase
  COL_WIDTHS = [20, 60, 140, 70, 70, 70, 70]

  def show
    render_header

    @summary.summaries_by_year.each_with_index do |year_record, year_i|
      next_page unless year_i == 0
      year_record.children.each_with_index do |(month, month_record), month_i|
        month_record.children.each_with_index do |(day_idx, day10_record), day10_i|
          day10_record.children.each_with_index do |(project_id, project_record), project_i|
            render_project_summary(project_id, project_record, day10_record, (day10_i == 0 && project_i == 0), (project_i == 0))
          end
          render_10days_summary(day10_record)
        end
        render_monthly_summary(month_record)
      end
      render_yearly_summary(year_record)
    end
  end

  def render_project_summary(project_id, project_record, day10_record, show_month = false, show_date_range = false)
      render_row [(show_month ? "#{day10_record.date_range.begin.month}月" : ''),
                  (show_date_range ? day10_record.date_range_label : ''),
                  @summary.project_label(project_id),
                  project_record.receipt, project_record.payment, '', ''], COL_WIDTHS
  end

  def render_10days_summary(day10_record)
    hline COL_WIDTHS.take(2).inject(:+), bounds.width
    render_row ['', '', '', day10_record.receipt, day10_record.payment, day10_record.balance, day10_record.flow], COL_WIDTHS
    br
  end

  def render_monthly_summary(month_record)
    hline COL_WIDTHS[0], bounds.right
    render_row ['', '', "#{month_record.date_range.begin.month}月計", month_record.receipt, month_record.payment, month_record.balance, month_record.flow], COL_WIDTHS
    br
    hr
  end

  def render_yearly_summary(year_record)
    render_row ['', '', "#{year_record.date_range.begin.year}年計", year_record.receipt, year_record.payment, year_record.balance, year_record.flow], COL_WIDTHS
  end

  def render_header
    br
    br
    render_title '入出金レポート（全プロジェクトサマリ）'
    br
    br
    render_target_dates
    br
    render_currency_unit
    br
    br
    hr
    render_row ['', '', 'プロジェクト', '入金', '出金', '収支', 'キャッシュフロー'], COL_WIDTHS
    hr
  end
end
