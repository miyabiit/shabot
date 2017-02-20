class Report::PaymentReport < Report::ReportBase

  def initialize(pdf, payment)
    super(pdf)

    @payment = payment

    @colsizes = [70, 170, 70, bounds.width - 310]
  end

  def show
    @pdf.stroke_axis
    
    render_outer_line
    render_stamp_fields
    @pdf.move_cursor_to 700
    render_table
    render_comment
    render_etc
  end

  def render_outer_line
    @pdf.line_width = 0.5
    @pdf.dash(1)
    @pdf.stroke do
      @pdf.rectangle [0, bounds.height], bounds.width, bounds.height
    end
    @pdf.undash
  end

  def render_stamp_fields
    @pdf.line_width = 0.5
    @pdf.stroke do
      @pdf.horizontal_line 310, bounds.width, :at => bounds.height
      @pdf.horizontal_line 310, bounds.width, :at => 710
      6.times do |n|
        @pdf.vertical_line bounds.height, 710, :at => (310 + 40 * n)
      end
    end

    @pdf.fill_color "0000ff"
    @pdf.draw_text @payment.my_corporation&.name, :size => 12, :at => [5,760]
    @pdf.fill_color "000000"
    @pdf.draw_text '作成:' + @payment.created_at.strftime("%Y/%m/%d") , :size => 10, :at => [325,760]
    @pdf.draw_text '更新:' + @payment.updated_at.strftime("%Y/%m/%d") , :size => 10, :at => [420,760]
    @pdf.draw_text "支払申請書", :size => 18, :at => [5,730]
    @pdf.draw_text "No." + @payment.slip_no.to_s , :size => 12, :at => [5,710]
  end

  alias mc make_cell

  def render_table
    cell_style_opts = {overflow: :shrink_to_fit, size: 12, height: 25}
    table([
      [mc('個人コード', width: @colsizes[0]), mc(@payment.user&.member_code&.to_s, width: @colsizes[1]), mc('申請者', width: @colsizes[2]), mc(@payment.user&.name, width: @colsizes[3])],
      [mc('所属'), mc(@payment.user&.section&.to_s), mc('支払先'), mc(@payment.account&.name)],
      *(
        %W(１ ２ ３ ４ ５).map.with_index {|num, i| 
          [mc("勘定科目#{num}"), mc(@payment.payment_parts.at(i)&.item&.name), mc('金額'), mc(@payment.payment_parts.at(i)&.amount&.to_s(:delimited), align: :right)]
        }
      ),
      [mc('支払日'), make_table([[mc(@payment.payable_on&.to_s, width: 100), mc(@payment.payment_type&.text, align: :right, width: 70)]]) {|sub_table| sub_table.cells.border_width = 0},
       mc('計'), mc(@payment.total.to_s(:delimited), align: :right)],
      [mc('振込先'), mc(@payment.account&.bank), mc('支店・口座'), mc(@payment.account&.branch_long_label)],
      [mc('事業名'), mc(@payment.project&.name), mc('PROJECT'), mc(@payment.project&.category)],
      [mc('予算区分'), mc(@payment.budget_code), mc('振込手数料'), mc(@payment.fee_who_paid)],
      [mc('引落元'), mc(@payment.my_bank_label), mc('支店・口座'), mc(@payment.my_bank_branch_and_number_label)]
    ], cell_style: cell_style_opts) do |t|
      t.cells.border_width = 0.5
      t.row(7).border_top_width = 1
      t.row(7).border_bottom_width = 1
    end
  end

  def render_comment
    move_down 2
    bounding_box([0, cursor], width: bounds.width, height: 100) do
      stroke_bounds
      move_down 5
      bounding_box([5, cursor], width: bounds.width - 10, height: bounds.height - 10) do
        text_box '摘要・目的・効果', size: 10, at: [0, cursor]
        move_down 20
        text_box @payment.comment, size: 12, at: [0, cursor]
      end
    end
  end

  def render_etc
    move_down 5
    @pdf.text_box '(証憑等添付)', :size => 10, at: [5, cursor]
  end
end
