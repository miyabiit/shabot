# coding: utf-8

# 5日ごとの予測残高
class BankAccountBalancePer5day < ActiveRecord::Base
  belongs_to :bank_account_balance, inverse_of: :per5days

  validates :target_date, :amount, presence: true
end
