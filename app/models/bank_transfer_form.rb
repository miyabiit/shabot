# coding: utf-8

class BankTransferForm
  include ActiveAttr::Model

  attribute :target_date       , type: Date
  attribute :src_my_account_id , type: Integer
  attribute :dst_my_account_id , type: Integer
  attribute :src_item_id       , type: Integer
  attribute :dst_item_id       , type: Integer
  attribute :project_id        , type: Integer
  attribute :amount            , type: Integer
  attribute :comment

  attribute :user_id, type: Integer

  validates :target_date, :src_my_account_id, :dst_my_account_id, :src_item_id, :dst_item_id, :project_id, :amount, presence: true
  validate :my_account_has_account

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
        account_id: MyAccount.find(self.dst_my_account_id).account_id,
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
        account_id: MyAccount.find(self.src_my_account_id).account_id,
        my_account_id: self.dst_my_account_id,
        item_id: self.dst_item_id,
        project_id: self.project_id,
        amount: self.amount,
        comment: self.comment
      )
    end

    results
  end

  private

  def my_account_has_account
    src_my_account = MyAccount.find(self.src_my_account_id)
    dst_my_account = MyAccount.find(self.dst_my_account_id)
    unless src_my_account.account
      self.errors.add :src_my_account_id, '取引先が未設定です'
    end
    unless dst_my_account.account
      self.errors.add :dst_my_account_id, '取引先が未設定です'
    end
  end
end
