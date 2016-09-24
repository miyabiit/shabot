class Report::ReportBase
  extend Forwardable

  ROW_SIZE = 12
  FONT_SIZE = 8
  BR_SIZE = 12

  attr_reader :pdf
  def_delegators :@pdf, :text, :stroke_horizontal_line,:move_down, :cursor, :bounds, :float, :bounding_box, :stroke_bounds, :make_cell, :make_table, :table, :stroke_rectangle

  def initialize(pdf)
    @pdf = pdf
  end

  def draw_text(text, opts={})
    @pdf.draw_text text, opts.tap{|o| 
      if o[:at] && o[:at].is_a?(Vector)
        o[:at] = o[:at].to_a
      end
    }
  end

  def text_box(text, opts={})
    @pdf.text_box text, opts.tap{|o| 
      if o[:at] && o[:at].is_a?(Vector)
        o[:at] = o[:at].to_a
      end
    }
  end

  def hr
    @pdf.stroke_horizontal_rule
    next_page if cursor <= 0
  end

  def br
    @pdf.move_down BR_SIZE
    next_page if cursor <= 0
  end

  def hline(_begin, _end)
    @pdf.stroke_horizontal_line(_begin, _end)
  end

  def next_row
    @pdf.move_down ROW_SIZE
  end

  def next_page
    @pdf.start_new_page
    render_header
  end

  def render_header
    raise 'Must be implement "render_header" method!'
  end

  def render_row(values, col_widths, options={})
    values.each_with_index do |v, idx|
      str = case v
            when Fixnum
              v.to_s(:delimited)
            else
              v.to_s
            end
      align = case v
              when Fixnum
                :right
              else
                :left
              end
      padding_left = options[:padding_left]   || options[:padding_horizontal] || 0
      padding_right = options[:padding_right] || options[:padding_horizontal] || 0

      text_box str, size: FONT_SIZE, at: Vector[col_widths.take(idx).inject(0, :+) + padding_left, cursor], width: col_widths[idx]-(padding_left+padding_right), height: ROW_SIZE, valign: :center, align: align
    end
    next_row
    if cursor <= 0
      next_page
    end
  end
end
