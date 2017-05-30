# coding: utf-8

# NOTE:
#   ・推定日残高は推定日の24:00時点の予測残高
#   ・起算日残高は起算日の0:00時点の残高
class BankAccountBalance < ActiveRecord::Base
  belongs_to :my_account    
  has_many :per5days, -> { order(:id) }, class_name: 'BankAccountBalancePer5day', inverse_of: :bank_account_balance, dependent: :destroy

  attr_accessor :today

  def calculate
    raise 'Must be set "today"!' unless self.today

    # 推定日
    if self.estimated_on.present?
      self.estimate_date_amount = calculate_receipt_and_payment_amount(
        self.current_amount, self.based_on, self.estimated_on
      )
    end

    # 今月末
    self.current_month_amount = calculate_receipt_and_payment_amount(
      self.current_amount, self.based_on, self.today.end_of_month
    )
    
    # 来月末
    self.two_month_amount = calculate_receipt_and_payment_amount(
      self.current_amount, self.based_on, self.today.next_month.end_of_month
    )

    # 再来月末
    self.three_month_amount = calculate_receipt_and_payment_amount(
      self.current_amount, self.based_on, self.today.next_month.next_month.end_of_month
    )

    # 5日単位
    per5days.delete_all
    quantized_based_on = based_on
    4.times do
      quantized_based_on = quantize_date_by_5days(quantized_based_on)
      per5days.build(
        target_date: quantized_based_on,
        amount: calculate_receipt_and_payment_amount(self.current_amount, self.based_on, quantized_based_on)
      )
    end
  end

  def estimated_on_date_range
    if self.estimated_on.present?
      if self.based_on <= self.estimated_on
        self.based_on .. self.estimated_on
      else
        (self.estimated_on + 1) ... self.based_on
      end
    end
  end

  def receipt_headers
    ReceiptHeader.left_join_projects.with_my_account_id(my_account_id)
  end 

  def payment_headers
    PaymentHeader.left_join_projects.with_my_account_id(my_account_id)
  end 

  def calculate_receipt_and_payment_amount(amount, date_from, date_to)
    date_range, reverse = if date_from > date_to
                            [((date_to + 1) ... date_from), true]
                          else
                            [(date_from .. date_to), false]
                          end
    receipt_sum = receipt_headers.where(receipt_on: date_range).sum(:amount)
    payment_sum = payment_headers.joins(:payment_parts).where(payable_on: date_range).sum('payment_parts.amount')
    if reverse
      amount -= receipt_sum - payment_sum
    else
      amount += receipt_sum - payment_sum
    end
    amount
  end

  class <<self
    def calculate_all(bank_account_balances_params, estimated_on, based_on, today=Date.today)
      BankAccountBalance.transaction do
        BankAccountBalancePer5day.delete_all
        BankAccountBalance.delete_all
        bank_account_balances_params.each do |param|
          next if param[:my_account_id].blank?
          bank_account_balance = BankAccountBalance.new(
            my_account_id: param[:my_account_id],
            estimated_on: estimated_on,
            current_amount: (param[:current_amount].presence || 0),
            based_on: based_on,
            today: today
          )
          bank_account_balance.calculate
          bank_account_balance.save!
        end
      end
    end
  end

  private

  def quantize_date_by_5days(date)
    day = date.day
    quantized_day = ((day / 5) * 5) + 5
    if date == date.end_of_month.to_date
      date.next_month.beginning_of_month.since(4.days).to_date
    elsif quantized_day > 25
      date.end_of_month.to_date
    else
      date.since((quantized_day - date.day).days)
    end
  end
end
