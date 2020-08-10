class Wareki
  DEFS = [
    [(Date.new(1926, 12, 25)..Date.new(1989, 1, 7)), "昭和"],
    [(Date.new(1989,  1, 8)..Date.new(2019, 4, 30)), "平成"]
  ]

  def self.to_wareki(date)
    wareki = DEFS.find{|range, _| range.include?(date)}
    if wareki
      wareki_range, wareki_name = wareki
      year_diff = date.year - wareki_range.begin.year
      wareki_text = if year_diff == 0
                      wareki_name + '元年'
                    else
                      "#{wareki_name}#{year_diff+1}年"
                    end
      date&.strftime("#{wareki_text}%-m月%-d日")
    else
      date&.strftime('%Y年%-m月%-d日')
    end
  end
end
