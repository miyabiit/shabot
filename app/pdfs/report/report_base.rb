class Report::ReportBase
  extend Forwardable

  ROW_SIZE = 12
  FONT_SIZE = 8
  BR_SIZE = 12

  attr_reader :summary, :pdf
  def_delegators :@pdf, :text, :stroke_horizontal_line,:move_down, :cursor, :bounds

  def initialize(summary, pdf)
    @summary = summary
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
  end

  def br
    @pdf.move_down BR_SIZE
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

  def render_row(values, col_widths)
    values.each_with_index do |v, idx|
      text_box v.to_s, size: FONT_SIZE, at: Vector[col_widths.take(idx).inject(0, :+), cursor], width: col_widths[idx], height: ROW_SIZE, valign: :center
    end
    next_row
    if cursor <= 0
      next_page
    end
  end
end
