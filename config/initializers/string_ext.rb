class String
  def to_cp932
    [
      ["\u{00A2}", "\u{FFE0}"],
      ["\u{00A3}", "\u{FFE1}"],
      ["\u{00AC}", "\u{FFE2}"],
      ["\u{2016}", "\u{2225}"],
      ["\u{2014}", "\u{2015}"],
      ["\u{2012}", "\u{FF0D}"],
      ["\u{2212}", "\u{FF0D}"],
      ["\u{301C}", "\u{FF5E}"]
    ].inject(self) {|s, (before, after)|
      s.gsub(before, after)
    }.encode(Encoding::CP932, invalid: :replace, undef: :replace)
  end
end
