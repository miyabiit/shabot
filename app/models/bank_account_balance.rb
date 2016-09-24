# coding: utf-8

class BankAccountBalance < ActiveRecord::Base
  belongs_to :my_account    

  attr_accessor :today

  def calculate
    raise 'Must be set "today"!' unless self.today

    # 推定日
    if self.estimated_on.present?
      self.estimate_date_amount = calculate_receipt_and_payment_amount(
        self.current_amount, self.estimated_on_date_range, (self.today > self.estimated_on)
      )
    end

    # 今月末
    self.current_month_amount = calculate_receipt_and_payment_amount(
      self.current_amount, self.today .. self.today.end_of_month
    )
    
    # 来月末
    self.two_month_amount = calculate_receipt_and_payment_amount(
      self.current_amount, self.today .. self.today.next_month.end_of_month
    )

    # 再来月末
    self.three_month_amount = calculate_receipt_and_payment_amount(
      self.current_amount, self.today .. self.today.next_month.next_month.end_of_month
    )
  end

  def estimated_on_date_range
    if self.estimated_on.present?
      if self.today <= self.estimated_on
        self.today .. self.estimated_on
      else
        self.estimated_on .. (self.today - 1)
      end
    end
  end

  def receipt_headers
    ReceiptHeader.left_join_projects.with_my_account_id(my_account_id)
  end 

  def payment_headers
    PaymentHeader.left_join_projects.with_my_account_id(my_account_id)
  end 

  def calculate_receipt_and_payment_amount(amount, date_range, reverse=false)
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
    def calculate_all(bank_account_balances_params, estimated_on, today=Date.today)
      BankAccountBalance.transaction do
        BankAccountBalance.delete_all
        bank_account_balances_params.each do |param|
          next if param[:my_account_id].blank?
          bank_account_balance = BankAccountBalance.new(
            my_account_id: param[:my_account_id],
            estimated_on: estimated_on,
            current_amount: (param[:current_amount].presence || 0),
            today: today
          )
          bank_account_balance.calculate
          bank_account_balance.save!
        end
      end
    end
  end
end
