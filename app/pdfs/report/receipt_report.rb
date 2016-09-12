class Report::ReceiptReport < Report::ReportBase

  def initialize(pdf, receipt)
    super(pdf)

    @account_address = '　'
    @account_post = '　'
    @account_user_name = '　'

    @title = "入 金 予 定 票"

    @receipt = receipt
  end

  def show
    render_account_info
    render_create_date
    render_title
    render_company
    render_content
  end

  def render_account_info
    @pdf.line_width = 0.5
    float do
      bounding_box([0, cursor], width: 220, height: 90) do
        stroke_bounds
        bounding_box([5, cursor+5], width: 210, height: 80) do
          move_down 10
          text @account_address, size: 10
          move_down 20
          text @receipt.account&.name, size: 14
          move_down 2
          text @account_post, size: 10
          text "　#{@account_user_name}", size: 12
        end
      end
    end
  end

  def render_create_date
    float do
      move_down 100
      text_box Wareki.to_wareki(Date.today), size: 12, at: [0, cursor], width: bounds.width, height: 12, align: :right, valign: :center
    end
  end

  def render_title
    float do
      move_down 120
      text_box @title, size: 24, at: [0, cursor], width: bounds.width, height: 24, align: :center, valign: :center
    end
  end

  def render_company
    @pdf.line_width = 1
    float do
      move_down 180
      bounding_box([0, cursor], width: bounds.width, height: 180) do
        text "〒102-0093 東京都千代田区平河町2-14-7コハセビル4F", size: 10, align: :right
        move_down 2
        text "株式会社シャロンテック", size: 14, align: :right
        move_down 2
        text "TEL 03-3239-2431 FAX 03-3239-2438", size: 10, align: :right

        move_down 20
        
        sign_cell_opts = {width: 60, height: 55}
        table [
          [make_cell(content: '検印', align: :center), make_cell(content: '検印', align: :center), make_cell(content: '担当', align: :center)],
          [make_cell(sign_cell_opts), make_cell(sign_cell_opts), make_cell(sign_cell_opts)],
        ], position: :right, cell_style: {padding: 2}
      end
    end
  end

  def render_content
    @pdf.line_width = 1

    move_down 340

    bounding_box([30, cursor], width: bounds.width-30, height: bounds.height-340) do
      stroke_rectangle [0, cursor], 220, 24
      bounding_box([5, cursor], width: 210, height: 24) do
        float do
          text_box "入金予定金額", align: :left, valign: :center
        end
        float do
          text_box "#{@receipt.amount&.to_s(:delimited)} 円", valign: :center, align: :right
        end
      end

      move_down 14
      
      table [
        [make_cell('内 訳', align: :center, width: bounds.width - 120), make_cell('金 額', align: :center, width: 120)],
        [
          make_cell([@receipt.comment, @receipt.item&.name].compact.join('　'), align: :left, height: 200),
          make_cell(@receipt.amount&.to_s(:delimited), align: :right)
        ]
      ]

      move_down 10

      float do
        text_box '振込先', at: [0, cursor], align: :left, valign: :center, width: 80, height: 20
        my_account = @receipt.my_account || @receipt.project&.my_account
        text_box "#{my_account&.bank_long_label}", at: [80, cursor], align: :left, valign: :center, width: bounds.width - 100, height: 20
      end

      move_down 20

      float do
        text_box '支払期日', at: [0, cursor], align: :left, valign: :center, width: 80, height: 20
        text_box "#{Wareki.to_wareki(@receipt.receipt_on)}", at: [80, cursor], align: :left, valign: :center, width: bounds.width - 100, height: 20
      end
      
      move_down 30

      text "備 考"
    end
  end
end
