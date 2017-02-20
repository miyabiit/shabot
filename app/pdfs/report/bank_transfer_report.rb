class Report::BankTransferReport < Report::ReportBase

  def initialize(pdf, bank_transfer)
    super(pdf)

    @bank_transfer = bank_transfer
  end

  def show
    render_header
  end

  def render_header
    move_down 18
    render_create_date
    move_down 12
    render_title '口座別入出金明細'
  end

  def render_create_date
    text_box "#{Date.today.strftime('%Y/%m/%d')}", size: 8, at: [0, cursor], width: bounds.width, height: 10, align: :right, valign: :center
  end

  def render_title(title)
    text_box title, size: 16, at: [0, cursor], width: bounds.width, height: 16, align: :center, valign: :center
  end
end
