class Report::InvoiceReport < Report::ReceiptReport
  def initialize(pdf, receipt)
    super(pdf, receipt)

    @invoice_info = @receipt.receipt_invoice_info || ReceiptInvoiceInfo.new
    @title = "ご 請 求 書"
    @account_address = "#{@invoice_info.dst_address1}\n#{@invoice_info.dst_address2}"
    @company_address1 = "〒#{@invoice_info.src_post_num} #{@invoice_info.src_address1}"
    @company_address2 = "#{@invoice_info.src_address2}"
  end

  def render_header
  end

  def render_account_info
    @pdf.line_width = 0.5
    float do
      bounding_box([0, cursor], width: 220, height: 90) do
        stroke_bounds
        bounding_box([5, cursor+5], width: 210, height: 90) do
          move_down 10
          text_box "〒#{@invoice_info.dst_post_num}", size: 9, at: [0, cursor], width: 70
          text_box @account_address, size: 9, at: [60, cursor], width: (bounds.width - 70)
          move_down 38
          text_box @receipt.account&.name, size: 12, at: [0, cursor], width: bounds.width if @receipt.account
          move_down 26
          text "#{@invoice_info.dst_person_name}", size: 12
        end
      end
    end
  end

  def render_company
    @pdf.line_width = 1
    float do
      move_down 160
      bounding_box([0, cursor], width: bounds.width, height: 180) do
        text @company_address1 , size: 9, align: :right
        move_down 2
        text @company_address2 , size: 9, align: :right
        move_down 4
        text @receipt.my_corporation&.name || '', size: 12, align: :right
        move_down 4
        text "TEL #{@invoice_info.src_tel} FAX #{@invoice_info.src_fax}", size: 9, align: :right
        move_down 20
        
        render_signs
      end
    end
  end

  def render_content
    @pdf.line_width = 1

    move_down 340

    bounding_box([30, cursor], width: bounds.width-30, height: bounds.height-340) do
      text "下記の通りご請求申し上げます。", align: :left
      br
      stroke_rectangle [0, cursor], 220, 24
      bounding_box([5, cursor], width: 210, height: 24) do
        float do
          text_box "ご請求金額", align: :left, valign: :center
        end
        float do
          text_box "#{@receipt.amount&.to_s(:delimited)} 円", valign: :center, align: :right
        end
      end

      move_down 14
      
      table([
        [make_cell('内 訳', align: :center, width: bounds.width - 280, colspan: 2), make_cell('金 額', align: :center, width: 120)],
        [
          make_cell(@receipt.comment, align: :left, width: bounds.width - 170, height: 200),
          make_cell(@receipt.tax_type&.to_sym == :in ? '(税込)' : '', align: :center, width: 50),
          make_cell(@receipt.amount&.to_s(:delimited), align: :right)
        ]
      ]) do |t|
        t.column(0).borders = [:left, :top, :bottom]
        t.column(1).borders = [:right, :top, :bottom]
      end

      move_down 10

      text_box 'お振込先', at: [0, cursor], align: :left, valign: :top, width: 80, height: 20
      bounding_box([80, cursor], width: (bounds.width - 80), height: 30) do
        my_account = @receipt.my_account || @receipt.project&.my_account
        text "#{@invoice_info.trans_dst_bank_info}", align: :left 
        text "#{@invoice_info.trans_dst_bank_account_name}", align: :left
      end


      float do
        text_box 'お支払期日', at: [0, cursor], align: :left, valign: :center, width: 80, height: 20
        text_box "#{Wareki.to_wareki(@receipt.receipt_on)}", at: [80, cursor], align: :left, valign: :center, width: bounds.width - 100, height: 20
      end
      
      move_down 30

      text "備 考"
    end
  end
end
