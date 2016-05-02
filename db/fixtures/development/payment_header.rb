# coding: utf-8

srand 1234

((Date.parse('2015/1/1'))..(Date.parse('2016/5/1'))).each_with_index do |date, idx|
  PaymentHeader.seed do |r|
    r.id = idx+1
    r.user_id = rand(1..10)
    r.account_id = rand(1..10)
    r.payable_on = date
    r.project_id = rand(1..20)
    r.comment = "テスト用自動生成データ"
    r.my_account_id = rand(1..5)
    r.planned = (rand(0..1) == 1)
    r.org_name = PaymentHeader::ORG_NAMES[rand(0..5)]
    r.fee_who_paid = PaymentHeader::WHO_PAY[rand(0..1)]
    r.slip_no = SlipNo.get_num
  end  
end

idx = 1
PaymentHeader.all.find_each do |p|
  (rand(1..3)).times do
    PaymentPart.seed do |r|
      r.id = idx 
      r.payment_header_id = p.id
      r.item_id = rand(1..38)
      r.amount = rand(10000..10000000)
    end
    idx += 1
  end
end

