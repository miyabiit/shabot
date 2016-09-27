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
        balance = BankAccountBalance.new(my_account: my_accounts(:test_1), current_amount: 100, estimated_on: '2015/11/15', based_on: Date.new(2015, 11, 5), today: Date.new(2015, 11, 5))
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
        balance = BankAccountBalance.new(my_account: my_accounts(:test_1), current_amount: 100, estimated_on: '2016/01/1', based_on: Date.new(2016, 1, 15), today: Date.new(2016, 1, 15))
        balance.calculate

        # estimate_date_amount
        date_range = Date.new(2016, 1, 2) .. Date.new(2016, 1, 14)
        assert_equal (100 + payment_sum(date_range) - receipt_sum(date_range)), balance.estimate_date_amount
      end
    end
    describe "起算日が過去(先月)" do
      it "当月末、翌月末、翌々月末は当日基準で計算されること" do
        balance = BankAccountBalance.new(my_account: my_accounts(:test_1), current_amount: 100, based_on: Date.new(2015, 10, 15), today: Date.new(2015, 11, 5))
        balance.calculate

        # current_month_amount 
        date_range = Date.new(2015, 10, 5) .. Date.new(2015, 11, 30)
        assert_equal (100 - payment_sum(date_range) + receipt_sum(date_range)), balance.current_month_amount

        # two_month_amount
        date_range = Date.new(2015, 10, 5) .. Date.new(2015, 12, 31)
        assert_equal (100 - payment_sum(date_range) + receipt_sum(date_range)), balance.two_month_amount

        # three_month_amount
        date_range = Date.new(2015, 10, 5) .. Date.new(2016, 1, 31)
        assert_equal (100 - payment_sum(date_range) + receipt_sum(date_range)), balance.three_month_amount
      end
    end
    describe "起算日が未来(次月)" do
      it "当月末、翌月末、翌々月末は当日基準で計算されること" do
        balance = BankAccountBalance.new(my_account: my_accounts(:test_1), current_amount: 100, based_on: Date.new(2015, 12, 15), today: Date.new(2015, 11, 5))
        balance.calculate

        # current_month_amount 
        date_range = Date.new(2015, 12, 1) ... Date.new(2015, 12, 15)
        assert_equal (100 + payment_sum(date_range) - receipt_sum(date_range)), balance.current_month_amount

        # two_month_amount
        date_range = Date.new(2015, 12, 15) .. Date.new(2015, 12, 31)
        assert_equal (100 - payment_sum(date_range) + receipt_sum(date_range)), balance.two_month_amount

        # three_month_amount
        date_range = Date.new(2015, 12, 15) .. Date.new(2016, 1, 31)
        assert_equal (100 - payment_sum(date_range) + receipt_sum(date_range)), balance.three_month_amount
      end
    end
  end

  describe "#calculate_all" do
    it '全口座の金額計算が行われること' do
      BankAccountBalance.calculate_all([
        { my_account_id: my_accounts(:test_1).id },
        { my_account_id: my_accounts(:test_2).id }
      ], nil, Date.today)
      assert_equal MyAccount.count, BankAccountBalance.count
    end

    it '入金口座/出金口座が未設定でもプロジェクトの口座を利用して計算すること' do
      BankAccountBalance.calculate_all([
        { my_account_id: my_accounts(:test_1).id }
      ], '2016-2-1', Date.new(2016,2,1))
      assert_equal 11111, BankAccountBalance.where(my_account: my_accounts(:test_1)).first.estimate_date_amount
    end
  end
end
