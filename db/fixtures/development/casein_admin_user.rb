# coding: utf-8

require 'i18n'
I18n.locale = :ja
FFaker::Locale.code 'JA'
FFaker::Locale.language 'Japanese'

(2..11).each do |id|
  Casein::AdminUser.seed do |u|
    gimei = Gimei.name
    login = Romaji.kana2romaji(gimei.last.katakana)
    u.id = id
    u.login = login
    u.name = gimei.kanji
    u.email = FFaker::Internet.safe_email
    u.password = login
    u.password_confirmation = login
  end
end
