require 'csv'

class PaymentCSV
  HEADER = [
    '支払日',
    '伝票No.',
    'プロジェクト名',
    '費目',
    '金額',
    '計画区分',
    '処理済',
    '月別一覧出力対象外',
    '作成者',
    '請求元法人',
    '請求先',
    '予算区分',
    '支払処理区分',
    '振込手数料',
    '引落元口座',
    '引落元銀行支店名',
    '引落元銀行種別',
    '引落元銀行口座番号',
    '摘要・目的・効果'
  ]

  def initialize(from, to)
    @from = from
    @to = to
  end

  def generate
    return "" if @to < @from

    payments = PaymentHeader.includes({project: :my_account}, :user, :account, :my_account, {payment_parts: :item})
                            .payable_on_is_not_null.where(payable_on: (@from..@to))
    CSV.generate(:headers => HEADER, :write_headers => true) {|csv|
      payments.find_each do |p|
        p.payment_parts.each do |part|
          my_account = p.my_account || p.try(:project).my_account
          csv << [
            p.payable_on,
            p.slip_no,
            p.try(:project).try(:name_and_category),
            part.try(:item).try(:name),
            part.amount,
            p.planned,
            p.processed,
            p.no_monthly_report,
            p.try(:user).try(:name),
            p.org_name,
            p.try(:account).try(:name),
            p.budget_code,
            p.payment_type&.text,
            p.fee_who_paid,
            my_account.try(:bank),
            my_account.try(:bank_branch),
            my_account.try(:category),
            "=\"#{my_account.try(:ac_no)}\"",
            p.comment
          ]
        end
      end
    }.to_cp932
  end
end
