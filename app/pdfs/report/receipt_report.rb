class Report::ReceiptReport < Report::ReportBase

  def initialize(pdf, receipt)
    super(pdf)

    @account_address = '[入金元]'
    @account_post = '　'
    @account_user_name = '　'

    @title = "入 金 予 定 票"

    @receipt = receipt
  end

  def show
    render_account_info
    render_slip_no
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
        bounding_box([5, cursor+5], width: 210, height: 90) do
          move_down 10
          text_box @account_address, size: 10, at: [0, cursor], width: bounds.width
          move_down 24
          text_box @receipt.account&.name, size: 14, at: [0, cursor], width: bounds.width if @receipt.account
#           move_down 34
#           text @account_post, size: 10
#           text "　#{@account_user_name}", size: 12
        end
      end
    end
  end

  def render_slip_no
    float do
      move_down 78
      text_box "No. #{@receipt.id}", size: 12, at: [0, cursor], width: bounds.width, height: 12, align: :right, valign: :center
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
        br
        text @receipt.my_corporation&.name || '', size: 14, align: :right
        br

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
        [make_cell('費 目', align: :center, width: 130), make_cell('明 細', align: :center, width: bounds.width - 250), make_cell('金 額', align: :center, width: 120)],
        [
          make_cell(@receipt.item&.name, align: :left, height: 200),
          make_cell(@receipt.comment, align: :left),
          make_cell(@receipt.amount&.to_s(:delimited), align: :right)
        ]
      ]

      move_down 10

      float do
        text_box '入金口座', at: [0, cursor], align: :left, valign: :center, width: 80, height: 20
        my_account = @receipt.my_account || @receipt.project&.my_account
        text_box "#{my_account&.bank_long_label}", at: [80, cursor], align: :left, valign: :center, width: bounds.width - 100, height: 20
      end

      move_down 20

      float do
        text_box '入金日', at: [0, cursor], align: :left, valign: :center, width: 80, height: 20
        text_box "#{Wareki.to_wareki(@receipt.receipt_on)}", at: [80, cursor], align: :left, valign: :center, width: bounds.width - 100, height: 20
      end
      
      move_down 30

      text "備 考"
    end
  end
end
