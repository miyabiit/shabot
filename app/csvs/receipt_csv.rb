require 'csv'

class ReceiptCSV
  HEADER = ['入金予定日', 'プロジェクト名', '費目', '金額', '作成者', '入金元', '入金口座', '摘要・目的・効果']

  def initialize(from, to)
    @from = from
    @to = to
  end

  def generate
    return "" if @to < @from

    receipts = ReceiptHeader.includes({project: :my_account} , :item, :user, :account, :my_account)
                            .receipt_on_is_not_null.where(receipt_on: (@from..@to))
    CSV.generate(:headers => HEADER, :write_headers => true) {|csv|
      receipts.find_each do |r|
        csv << [r.receipt_on, r.try(:project).try(:name_and_category), r.try(:item).try(:name), r.amount, r.try(:user).try(:name), r.try(:account).try(:name), r.try(:my_account).try(:bank) || p.try(:project).try(:my_account).try(:bank), r.comment]
      end
    }.encode(Encoding::SJIS)
  end
end
