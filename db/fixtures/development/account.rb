# coding: utf-8

require 'i18n'
I18n.locale = :ja
FFaker::Locale.code 'JA'
FFaker::Locale.language 'Japanese'

(1..10).each do |id|
  Account.seed do |a|
    a.id = id
    a.name = "テスト取引先会社#{id}"
    a.bank = "テスト銀行#{id}"
    a.bank_branch = "テスト支店#{id}"
    a.category = (id % 2 == 0) ? '普通' : '当座'
    a.ac_no = (1234567890123456 + id).to_s
  end
end
