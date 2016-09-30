module Enums
  module OrgNameEnum
    extend Enumerize

    enumerize :org_name, in: %w(シャロンテック 聚楽荘 JAM ベルク ブルームコンサルティング その他)
  end
end
