class Report::PaymentReceiptReportBase < Report::ReportBase
  attr_reader :summary

  def initialize(summary, pdf)
    super(pdf)

    @summary = summary
  end

  def render_title(title)
    text_box title, size: 16, at: [0, cursor], width: bounds.width, height: 16, align: :center, valign: :center
  end

  def render_project_name(project)
    text_box "プロジェクト名: #{project.try(:name_and_category)}", size: 10, at: [0, cursor], width: bounds.width, height: 10, align: :left, valign: :center
  end

  def render_target_dates
    text_box "#{@summary.from.strftime('%Y/%m/%d')} 〜 #{@summary.to.strftime('%Y/%m/%d')}", size: 10, at: [0, cursor], width: bounds.width, height: 10, align: :right, valign: :center
  end

  def render_currency_unit
    text_box "（単位：円）", size: 10, at: [0, cursor], width: bounds.width, height: 10, align: :right, valign: :center
  end

  def render_detail_category(category_name)
    text_box category_name, size: 10, at: [0, cursor], width: bounds.width, height: 10, align: :left, valign: :center
  end
end
