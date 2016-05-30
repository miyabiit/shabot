class String
  def to_cp932
    [
      ["\u00A2", "\uFFE0"],
      ["\u00A3", "\uFFE1"],
      ["\u00AC", "\uFFE2"],
      ["\u2016", "\u2225"],
      ["\u2014", "\u2015"],
      ["\u2012", "\uFF0D"],
      ["\u2212", "\uFF0D"],
      ["\u301C", "\uFF5E"],
		  ["\u3231", '(株)'],
		  ["\u3232", '(有)'],
      ["\u2460", '(1)'],
		  ["\u2461", '(2)'],
		  ["\u2462", '(3)'],
		  ["\u2463", '(4)'],
		  ["\u2464", '(5)'],
		  ["\u2465", '(6)'],
		  ["\u2466", '(7)'],
		  ["\u2467", '(8)'],
		  ["\u2468", '(9)']
    ].inject(self) {|s, (before, after)|
      s.gsub(before, after)
    }.encode(Encoding::CP932, invalid: :replace, undef: :replace)
  end
end
