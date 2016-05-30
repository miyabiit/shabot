# coding: utf-8

srand 1234

((Date.parse('2015/1/1'))..(Date.parse('2016/5/1'))).each_with_index do |date, idx|
  ReceiptHeader.seed do |r|
    r.id = idx+1
    r.user_id = rand(1..10)
    r.account_id = rand(1..10)
    r.receipt_on = date
    r.project_id = rand(1..20)
    r.comment = "テスト用自動生成データ"
    r.item_id = rand(1..38)
    r.amount = rand(10000..10000000)
    r.my_account_id = rand(1..5)
  end  
end
