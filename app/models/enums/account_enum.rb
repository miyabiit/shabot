module Enums
  module AccountEnum
    extend Enumerize

    enumerize :category, in: %w(普通 当座 ー)
  end
end
