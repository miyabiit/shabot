# coding: utf-8
require 'i18n'
I18n.locale = :ja
FFaker::Locale.code 'JA'
FFaker::Locale.language 'Japanese'

(1..20).each do |idx|
  Project.seed do |p|
    address = Gimei.address
    p.id = idx
    p.name = "プロジェクト#{idx}"
    p.category = address.city.kanji
  end
end
