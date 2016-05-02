class Report::AllProjectReport < Report::ReportBase
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
                  project_record.receipt.to_s(:delimited), project_record.payment.to_s(:delimited), '', ''], COL_WIDTHS
  end

  def render_10days_summary(day10_record)
    hline COL_WIDTHS.take(2).inject(:+), bounds.width
    render_row ['', '', '', day10_record.receipt.to_s(:delimited), day10_record.payment.to_s(:delimited), day10_record.balance.to_s(:delimited), day10_record.flow.to_s(:delimited)], COL_WIDTHS
    br
  end

  def render_monthly_summary(month_record)
    hline COL_WIDTHS[0], bounds.right
    render_row ['', '', "#{month_record.date_range.begin.month}月計", month_record.receipt.to_s(:delimited), month_record.payment.to_s(:delimited), month_record.balance.to_s(:delimited), month_record.flow.to_s(:delimited)], COL_WIDTHS
    br
    hr
  end

  def render_yearly_summary(year_record)
    render_row ['', '', "#{year_record.date_range.begin.year}年計", year_record.receipt.to_s(:delimited), year_record.payment.to_s(:delimited), year_record.balance.to_s(:delimited), year_record.flow.to_s(:delimited)], COL_WIDTHS
  end

  def render_header
    br
    br
    text_box '入出金レポート（全プロジェクトサマリ）', size: 16, at: [0, cursor], width: bounds.width, height: 16, align: :center, valign: :center
    br
    br
    text_box "#{@summary.from.strftime('%Y/%m/%d')} 〜 #{@summary.to.strftime('%Y/%m/%d')}", size: 10, at: [0, cursor], width: bounds.width, height: 10, align: :right, valign: :center
    br
    text_box "（単位：円）", size: 10, at: [0, cursor], width: bounds.width, height: 10, align: :right, valign: :center
    br
    br
    hr

    ['', '', 'プロジェクト', '入金', '出金', '収支', 'キャッシュフロー'].each_with_index do |header_title, idx|
      text_box header_title, size: FONT_SIZE, at: Vector[COL_WIDTHS.take(idx).inject(0, :+), cursor], width: COL_WIDTHS[idx], height: ROW_SIZE, valign: :center
    end
    next_row

    hr
  end
end
