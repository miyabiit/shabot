#coding: utf-8

class PDFBase < Prawn::Document

  def initialize(opts={})
    super(
      {
        :page_size => 'A4', 
        :page_layout => :portrait,
        :margin => 30,
        :left_margin => 60,
        :bottom_margin => 40
      }.merge(opts)
    )
    font Rails.root.to_s + '/' + "vendor/fonts/ipaexg.ttf"
  end

  def render_page_number
    number_pages "<page> / <total>", at: [bounds.right - 100, bounds.top - 8], size: 8, width: 100, align: :right
  end
end
