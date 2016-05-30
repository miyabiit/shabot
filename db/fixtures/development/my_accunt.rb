# coding: utf-8

MyAccount.seed do |m|
  m.id = 1
  m.bank = '三菱東京UFJ銀行'  
  m.bank_branch = 'テスト支店'
  m.category = '普通'
  m.ac_no = '1111111111111111'
end
MyAccount.seed do |m|
  m.id = 2
  m.bank = 'みずほ銀行'  
  m.bank_branch = 'テスト支店'
  m.category = '当座'
  m.ac_no = '2222222222222222'
end
MyAccount.seed do |m|
  m.id = 3
  m.bank = 'ゆうちょ銀行'  
  m.bank_branch = 'テスト支店'
  m.category = '普通'
  m.ac_no = '3333333333333333'
end
MyAccount.seed do |m|
  m.id = 4
  m.bank = '新生銀行'  
  m.bank_branch = 'テスト支店'
  m.category = '当座'
  m.ac_no = '4444444444444444'
end
MyAccount.seed do |m|
  m.id = 5
  m.bank = 'ジャパンネット銀行'  
  m.bank_branch = 'テスト支店'
  m.category = '普通'
  m.ac_no = '5555555555555555'
end
