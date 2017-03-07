require 'test_helper'

class BankTransferTest < ActiveSupport::TestCase
  describe "#transfer!" do
    let!(:form) {
      BankTransfer.new(
        target_date: '2016-11-1',
        src_my_account_id: my_accounts(:test_1).id,
        dst_my_account_id: my_accounts(:test_2).id,
        src_item_id: items(:test_1).id,
        dst_item_id: items(:test_2).id,
        project_id: projects(:test_1).id,
        amount: 12345,
        comment: '資金移動テスト',
        user_id: casein_admin_users(:taro).id
      )
    }
    it 'success bank transfer' do
      bank_transfer = form.transfer!
      bank_transfer.reload
      payment = bank_transfer.payment_header
      receipt = bank_transfer.receipt_header

      # bank_transfer
      assert_equal Date.new(2016, 11, 1), bank_transfer.target_date
      assert_equal my_accounts(:test_1).id,  bank_transfer.src_my_account_id
      assert_equal my_accounts(:test_2).id,  bank_transfer.dst_my_account_id
      assert_equal items(:test_1).id,  bank_transfer.src_item_id
      assert_equal items(:test_2).id,  bank_transfer.dst_item_id
      assert_equal projects(:test_1).id,  bank_transfer.project_id
      assert_equal 12345,  bank_transfer.amount
      assert_equal '資金移動テスト',  bank_transfer.comment
      assert_equal casein_admin_users(:taro).id, bank_transfer.user_id

      # payment
      assert_equal casein_admin_users(:taro).id, payment.user_id
      assert_equal -1, payment.account_id
      assert_equal Date.new(2016, 11, 1), payment.payable_on
      assert_equal projects(:test_1).id, payment.project_id
      assert_equal my_corporations(:test_1).code, payment.corporation_code
      assert_equal '資金移動テスト', payment.comment
      assert_equal '自社負担', payment.fee_who_paid
      assert_equal my_accounts(:test_1).id, payment.my_account_id
      assert_equal false, payment.planned
      assert_equal true, payment.processed
      assert_equal casein_admin_users(:taro).id, payment.process_user_id
      assert_equal Date.new(2016, 11, 1), payment.process_date
      assert_equal true,  payment.no_monthly_report
      assert_equal 1, payment.payment_parts.count
      payment_part = payment.payment_parts.first
      assert_equal items(:test_1).id, payment_part.item_id
      assert_equal 12345, payment_part.amount
      

      # receipt
      assert_equal casein_admin_users(:taro).id, receipt.user_id
      assert_equal -1, receipt.account_id
      assert_equal Date.new(2016, 11, 1), receipt.receipt_on
      assert_equal projects(:test_1).id, receipt.project_id
      assert_equal my_corporations(:test_2).code, receipt.corporation_code
      assert_equal '資金移動テスト', receipt.comment
      assert_equal items(:test_2).id, receipt.item_id
      assert_equal 12345, receipt.amount
      assert_equal my_accounts(:test_2).id, receipt.my_account_id
      assert_equal false, receipt.planned
      assert_equal true, receipt.no_monthly_report
    end
  end
end
