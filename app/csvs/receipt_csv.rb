require 'csv'

class ReceiptCSV
  HEADER = [
    '入金日',
    '伝票No.',
    'プロジェクト名',
    '費目',
    '消費税区分',
    '金額',
    '計画区分',
    '月別一覧出力対象外',
    '作成者',
    '入金先法人',
    '入金元',
    '入金先口座',
    '入金先銀行支店名',
    '入金先銀行種別',
    '入金先銀行口座番号',
    '摘要・目的・効果']

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
        my_account = r.my_account || r.project&.my_account
        csv << [
          r.receipt_on,
          r.id,
          r.project&.name_and_category,
          r.item&.name,
          r.tax_type&.text,
          r.amount,
          r.planned,
          r.no_monthly_report,
          r.user&.name,
          r.my_corporation&.name,
          r.account&.name,
          my_account&.bank,
          my_account&.bank_branch,
          my_account&.category,
          "=\"#{my_account&.ac_no}\"",
          r.comment
        ]
      end
    }.to_cp932
  end
end
