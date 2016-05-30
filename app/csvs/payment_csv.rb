require 'csv'

class PaymentCSV
  HEADER = ['支払日', 'プロジェクト名', '費目', '金額', '計画区分', '作成者', '請求元法人', '請求先', '予算区分', '振込手数料', '引落元口座', '摘要・目的・効果']

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
          csv << [p.payable_on, p.try(:project).try(:name_and_category), part.try(:item).try(:name), part.amount, p.planned, p.try(:user).try(:name), p.org_name, p.try(:account).try(:name), p.budget_code, p.fee_who_paid, p.try(:my_account).try(:bank) || p.try(:project).try(:my_account).try(:bank), p.comment]
        end
      end
    }.encode(Encoding::SJIS)
  end
end
