require 'test_helper'

class PaymentReceiptSummaryTest < ActiveSupport::TestCase

  describe "#summaries_by_year" do
    let!(:summary) do
      PaymentReceiptSummary.new(Date.parse('2015/11/18'), Date.parse('2016/1/5'))
    end
    let (:summaries_by_year) { summary.summaries_by_year }

    def assert_summary_record(date_range, s)
      assert_equal date_range, s.date_range
      assert_equal ReceiptHeader.where(receipt_on: s.date_range).sum(:amount), s.receipt
      assert_equal PaymentHeader.joins(:payment_parts).where(payable_on: s.date_range).sum('payment_parts.amount'), s.payment
      assert_equal s.receipt - s.payment, s.balance
    end

    def assert_project_record(s)
      s.children.each do |project_id, record|
        assert_equal ReceiptHeader.where(project_id: project_id, receipt_on: record.date_range).sum(:amount) || 0, record.receipt
        assert_equal PaymentHeader.joins(:payment_parts)
                                  .where(project_id: project_id, payable_on: record.date_range)
                                  .sum('payment_parts.amount') || 0, record.payment
      end
    end

    it 'summaries_by_year is valid result' do
      assert_equal 2, summaries_by_year.count 
        
      before_date_range = (Date.parse('1999/1/1')...Date.parse('2015/11/18'))
      initial_flow = ReceiptHeader.where(receipt_on: before_date_range).sum(:amount) - PaymentHeader.joins(:payment_parts).where(payable_on: before_date_range).sum('payment_parts.amount')

      summaries_by_year[0].tap do |s|
        assert_summary_record Date.parse('2015/11/18')..Date.parse('2015/12/31'), s
        assert_equal s.balance + initial_flow, s.flow

        assert_equal 2, s.children.count 
        assert_equal [Date.parse('2015/11/1'), Date.parse('2015/12/1')], s.children.keys
        
        s.children[Date.parse('2015/11/1')].tap do |month_s|
          assert_summary_record Date.parse('2015/11/18')..Date.parse('2015/11/30'), month_s
          assert_equal month_s.balance + initial_flow, month_s.flow

          assert_equal [1, 2], month_s.children.keys

          month_s.children[1].tap do |day_s|
            assert_summary_record Date.parse('2015/11/18')..Date.parse('2015/11/20'), day_s
            assert_project_record day_s
            assert_equal day_s.balance + initial_flow, day_s.flow
          end

          month_s.children[2].tap do |day_s|
            assert_summary_record Date.parse('2015/11/21')..Date.parse('2015/11/30'), day_s
            assert_project_record day_s
            assert_equal month_s.children[1].flow + day_s.balance, day_s.flow
          end
        end

        s.children[Date.parse('2015/12/1')].tap do |month_s|
          month_s = s.children[Date.parse('2015/12/1')]
          assert_summary_record Date.parse('2015/12/1')..Date.parse('2015/12/31'), month_s
          assert_equal s.children[Date.parse('2015/11/1')].flow + month_s.balance, month_s.flow

          assert_equal [0, 1, 2], month_s.children.keys

          month_s.children[0].tap do |day_s|
            assert_summary_record Date.parse('2015/12/1')..Date.parse('2015/12/10'), day_s
            assert_project_record day_s
            assert_equal s.children[Date.parse('2015/11/1')].flow + day_s.balance, day_s.flow
          end

          month_s.children[1].tap do |day_s|
            assert_summary_record Date.parse('2015/12/11')..Date.parse('2015/12/20'), day_s
            assert_project_record day_s
            assert_equal month_s.children[0].flow + day_s.balance, day_s.flow
          end

          month_s.children[2].tap do |day_s|
            assert_summary_record Date.parse('2015/12/21')..Date.parse('2015/12/31'), day_s
            assert_project_record day_s
            assert_equal month_s.children[1].flow + day_s.balance, day_s.flow
          end
        end
      end

      summaries_by_year[1].tap do |s|
        assert_summary_record Date.parse('2016/1/1')..Date.parse('2016/1/5'), s
        assert_equal summaries_by_year[0].flow + s.balance, s.flow

        assert_equal [Date.parse('2016/1/1')], s.children.keys

        s.children[Date.parse('2016/1/1')].tap do |month_s|
          month_s = s.children[Date.parse('2016/1/1')]
          assert_summary_record Date.parse('2016/1/1')..Date.parse('2016/1/5'), month_s
          assert_equal summaries_by_year[0].flow + month_s.balance, month_s.flow

          assert_equal [0], month_s.children.keys

          month_s.children[0].tap do |day_s|
            assert_summary_record Date.parse('2016/1/1')..Date.parse('2016/1/5'), day_s
            assert_project_record day_s
            assert_equal summaries_by_year[0].flow + day_s.balance, day_s.flow
          end
        end
      end
    end
  end

  describe "#summaries_project_by_year" do
    let!(:summary) do
      PaymentReceiptSummary.new(Date.parse('2015/11/18'), Date.parse('2016/1/5'))
    end
    let (:summaries_by_year) { summary.summaries_project_by_year(projects(:test_1)) }

    def assert_summary_record(date_range, s)
      assert_equal date_range, s.date_range
      assert_equal ReceiptHeader.where(project_id: projects(:test_1)).where(receipt_on: s.date_range).sum(:amount), s.receipt
      assert_equal PaymentHeader.where(project_id: projects(:test_1)).joins(:payment_parts).where(payable_on: s.date_range).sum('payment_parts.amount'), s.payment
      assert_equal s.receipt - s.payment, s.balance
    end

    it 'summaries_project_by_year is valid result' do
      assert_equal 2, summaries_by_year.count 

      before_date_range = (Date.parse('1999/1/1')...Date.parse('2015/11/18'))
      initial_flow = ReceiptHeader.where(project_id: projects(:test_1)).where(receipt_on: before_date_range).sum(:amount) - PaymentHeader.where(project_id: projects(:test_1)).joins(:payment_parts).where(payable_on: before_date_range).sum('payment_parts.amount')

      summaries_by_year[0].tap do |s|
        assert_summary_record Date.parse('2015/11/18')..Date.parse('2015/12/31'), s
        assert_equal s.balance + initial_flow, s.flow

        assert_equal 2, s.children.count 
        assert_equal [Date.parse('2015/11/1'), Date.parse('2015/12/1')], s.children.keys
        
        s.children[Date.parse('2015/11/1')].tap do |month_s|
          assert_summary_record Date.parse('2015/11/18')..Date.parse('2015/11/30'), month_s
          assert_equal month_s.balance + initial_flow, month_s.flow

          assert_equal [1, 2], month_s.children.keys

          month_s.children[1].tap do |day_s|
            assert_summary_record Date.parse('2015/11/18')..Date.parse('2015/11/20'), day_s
            assert_equal day_s.balance + initial_flow, day_s.flow
          end

          month_s.children[2].tap do |day_s|
            assert_summary_record Date.parse('2015/11/21')..Date.parse('2015/11/30'), day_s
            assert_equal month_s.children[1].flow + day_s.balance, day_s.flow
          end
        end

        s.children[Date.parse('2015/12/1')].tap do |month_s|
          month_s = s.children[Date.parse('2015/12/1')]
          assert_summary_record Date.parse('2015/12/1')..Date.parse('2015/12/31'), month_s
          assert_equal s.children[Date.parse('2015/11/1')].flow + month_s.balance, month_s.flow

          assert_equal [0, 1, 2], month_s.children.keys

          month_s.children[0].tap do |day_s|
            assert_summary_record Date.parse('2015/12/1')..Date.parse('2015/12/10'), day_s
            assert_equal s.children[Date.parse('2015/11/1')].flow + day_s.balance, day_s.flow
          end

          month_s.children[1].tap do |day_s|
            assert_summary_record Date.parse('2015/12/11')..Date.parse('2015/12/20'), day_s
            assert_equal month_s.children[0].flow + day_s.balance, day_s.flow
          end

          month_s.children[2].tap do |day_s|
            assert_summary_record Date.parse('2015/12/21')..Date.parse('2015/12/31'), day_s
            assert_equal month_s.children[1].flow + day_s.balance, day_s.flow
          end
        end
      end

      summaries_by_year[1].tap do |s|
        assert_summary_record Date.parse('2016/1/1')..Date.parse('2016/1/5'), s
        assert_equal summaries_by_year[0].flow + s.balance, s.flow

        assert_equal [Date.parse('2016/1/1')], s.children.keys

        s.children[Date.parse('2016/1/1')].tap do |month_s|
          month_s = s.children[Date.parse('2016/1/1')]
          assert_summary_record Date.parse('2016/1/1')..Date.parse('2016/1/5'), month_s
          assert_equal summaries_by_year[0].flow + month_s.balance, month_s.flow

          assert_equal [0], month_s.children.keys

          month_s.children[0].tap do |day_s|
            assert_summary_record Date.parse('2016/1/1')..Date.parse('2016/1/5'), day_s
            assert_equal summaries_by_year[0].flow + day_s.balance, day_s.flow
          end
        end
      end
    end
  end

  describe "#break_by_10days" do
    let(:summary) { PaymentReceiptSummary.new(Date.parse('1999/7/1'), Date.parse('2999/12/31')) }

    it do
      result = summary.break_by_10days(Date.parse('2016/1/3'), Date.parse('2016/2/18'))
      # break for each 10 days
      assert_equal [
        ((Date.parse('2016/1/3').to_date)..(Date.parse('2016/1/10').to_date)),
        ((Date.parse('2016/1/11').to_date)..(Date.parse('2016/1/20').to_date)),
        ((Date.parse('2016/1/21').to_date)..(Date.parse('2016/1/31').to_date)),
        ((Date.parse('2016/2/1').to_date)..(Date.parse('2016/2/10').to_date)),
        ((Date.parse('2016/2/11').to_date)..(Date.parse('2016/2/18').to_date))
      ], result
      result = summary.break_by_10days(Date.parse('2016/1/3'), Date.parse('2016/1/10'))
      # last day equal 10 (boundary test)
      assert_equal [
        (Date.parse('2016/1/3')..Date.parse('2016/1/10'))
      ], result
      # first day equal 11 (boundary test)
      result = summary.break_by_10days(Date.parse('2016/1/11'), Date.parse('2016/1/15'))
      assert_equal [
        (Date.parse('2016/1/11')..Date.parse('2016/1/15'))
      ], result
    end
  end

end
