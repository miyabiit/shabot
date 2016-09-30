# coding: utf-8

class BankTransferForm
  include ActiveAttr::Model

  attribute :src_account_id    , type: Integer
  attribute :dst_account_id    , type: Integer
  attribute :target_date       , type: Date
  attribute :src_my_account_id , type: Integer
  attribute :dst_my_account_id , type: Integer
  attribute :src_item_id       , type: Integer
  attribute :dst_item_id       , type: Integer
  attribute :project_id        , type: Integer
  attribute :amount            , type: Integer
  attribute :comment

  attribute :user_id, type: Integer

  validates :src_account_id, :dst_account_id, :target_date, :src_my_account_id, :dst_my_account_id, :src_item_id, :dst_item_id, :project_id, :amount, presence: true

  def set_default_values
    self.target_date = Date.today
    if bank_transfer_item = Item.where(name: '資金移動').first
      self.src_item_id = bank_transfer_item.id
      self.dst_item_id = bank_transfer_item.id
    end
  end

  def create!
    raise ActiveRecord::RecordInvalid.new(self) unless self.valid?

    results = []

    ActiveRecord::Base.transaction do
      results << PaymentHeader.create!(
        user_id: self.user_id,
        payable_on: self.target_date,
        slip_no: SlipNo.get_num,
        org_name: 'シャロンテック',
        account_id: self.dst_account_id,
        my_account_id: self.src_my_account_id, 
        project_id: self.project_id,
        fee_who_paid: '自社負担',
        planned: false,
        processed: true,
        process_user_id: self.user_id,
        process_date: self.target_date,
        no_monthly_report: true,
        comment: self.comment,
        payment_parts_attributes: [{item_id: self.src_item_id, amount: self.amount}]
      )

      results << ReceiptHeader.create!(
        user_id: self.user_id,
        receipt_on: self.target_date,
        account_id: self.src_account_id,
        my_account_id: self.dst_my_account_id,
        item_id: self.dst_item_id,
        project_id: self.project_id,
        amount: self.amount,
        comment: self.comment
      )
    end

    results
  end
end
