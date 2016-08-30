require 'test_helper'

class BankAccountBalanceTest < ActiveSupport::TestCase
  describe "#calculate" do

    def payment_sum(payable_on)
      PaymentHeader.joins(:payment_parts).where(my_account: my_accounts(:test_1), payable_on: payable_on).sum('payment_parts.amount')
    end

    def receipt_sum(receipt_on)
      ReceiptHeader.where(my_account: my_accounts(:test_1), receipt_on: receipt_on).sum(:amount)
    end

    describe "推定日が未来" do
      it "金額計算結果が正しいこと" do
        balance = BankAccountBalance.new(my_account: my_accounts(:test_1), current_amount: 100, estimated_on: '2015/11/15', today: Date.new(2015, 11, 5))
        balance.calculate

        # estimate_date_amount
        date_range = Date.new(2015, 11, 5) .. Date.new(2015, 11, 15)
        assert_equal (100 - payment_sum(date_range) + receipt_sum(date_range)), balance.estimate_date_amount

        # current_month_amount 
        date_range = Date.new(2015, 11, 5) .. Date.new(2015, 11, 30)
        assert_equal (100 - payment_sum(date_range) + receipt_sum(date_range)), balance.current_month_amount

        # two_month_amount
        date_range = Date.new(2015, 11, 5) .. Date.new(2015, 12, 31)
        assert_equal (100 - payment_sum(date_range) + receipt_sum(date_range)), balance.two_month_amount

        # three_month_amount
        date_range = Date.new(2015, 11, 5) .. Date.new(2016, 1, 31)
        assert_equal (100 - payment_sum(date_range) + receipt_sum(date_range)), balance.three_month_amount
      end
    end
    describe "推定日が過去" do
      it "過去推定日の金額計算結果が正しいこと" do
        balance = BankAccountBalance.new(my_account: my_accounts(:test_1), current_amount: 100, estimated_on: '2016/01/1', today: Date.new(2016, 1, 15))
        balance.calculate

        # estimate_date_amount
        date_range = Date.new(2016, 1, 1) .. Date.new(2016, 1, 14)
        assert_equal (100 + payment_sum(date_range) - receipt_sum(date_range)), balance.estimate_date_amount
      end
    end
  end

  describe "#calculate_all" do
    it '全口座の金額計算が行われること' do
      BankAccountBalance.calculate_all([
        { my_account_id: my_accounts(:test_1) },
        { my_account_id: my_accounts(:test_2) }
      ], nil)
      assert_equal MyAccount.count, BankAccountBalance.count
    end
  end
end
