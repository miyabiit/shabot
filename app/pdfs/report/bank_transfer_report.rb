class Report::BankTransferReport < Report::ReportBase

  def initialize(pdf, bank_transfer, sub_title)
    super(pdf)

    @bank_transfer = bank_transfer
    @sub_title = sub_title
  end

  def show
    render_header
    move_down 32
    render_content
  end

  def render_header
    move_down 18
    render_title '資金移動指示'
    render_sub_title @sub_title
    move_down 32
    render_create_date
    move_down 32
    render_stumps
  end

  def render_content
    render_row ['実施日', @bank_transfer.target_date.strftime('%Y年%m月%d日')], [100, 150], font_size: 12
    br
    render_row ['金額', @bank_transfer.amount, '円'], [80, 105, 20], font_size: 12
    br
    render_bank '移動元', @bank_transfer.src_my_account
    br
    render_bank '移動先', @bank_transfer.dst_my_account
    br
    render_row ['経理処理', "移動元", @bank_transfer.src_item&.name, @bank_transfer.project&.name_and_category], [100, 60, 100, 240], font_size: 12
    br
    render_row ['', "移動先", @bank_transfer.dst_item&.name, @bank_transfer.project&.name_and_category], [100, 60, 100, 240], font_size: 12
    br
    render_row ['備考', @bank_transfer.comment], [100, bounds.width - 100], font_size: 12
  end

  def render_create_date
    text_box "#{Date.today.strftime('%Y年%m月%d日')}", size: 12, at: [0, cursor], width: bounds.width, height: 18, align: :right, valign: :center
  end

  def render_title(title)
    text_box title, size: 24, at: [0, cursor], width: bounds.width, height: 24, align: :center, valign: :center
  end

  def render_sub_title(sub_title)
    text_box sub_title, size: 18, at: [0, cursor], width: bounds.width, height: 24, align: :right, valign: :center
  end

  def render_stumps
    bounding_box([0, cursor], width: bounds.width, height: 100) do
      sign_cell_opts = {width: 60, height: 55}
      table [
        [make_cell(content: '承認', align: :center), make_cell(content: '承認', align: :center), make_cell(content: '担当', align: :center)],
        [make_cell(sign_cell_opts), make_cell(sign_cell_opts), make_cell(sign_cell_opts)],
      ], position: :right, cell_style: {padding: 2}
    end
  end

  def render_bank(title, my_account)
    render_row [title, "#{my_account.my_corporation&.name} 名義"], [100, 250], font_size: 12
    br
    render_row ['', my_account.bank_label], [100, 250], font_size: 12
    br
    render_row ['', my_account.ac_no_label], [100, 250], font_size: 12
  end
end
