# coding: utf-8

class BankTransfer < ActiveRecord::Base
  belongs_to :receipt_header, dependent: :destroy
  belongs_to :payment_header, dependent: :destroy

  belongs_to :project
  belongs_to :src_my_account, class_name: 'MyAccount', foreign_key: 'src_my_account_id'
  belongs_to :dst_my_account, class_name: 'MyAccount', foreign_key: 'dst_my_account_id'
  belongs_to :src_item, class_name: 'Item', foreign_key: 'src_item_id'
  belongs_to :dst_item, class_name: 'Item', foreign_key: 'dst_item_id'
  belongs_to :user, class_name: 'Casein::AdminUser', foreign_key: 'user_id'

  validates :target_date, :src_my_account_id, :dst_my_account_id, :src_item_id, :dst_item_id, :project_id, :amount, presence: true

  validate :my_account_has_corporation_code

  def set_default_values
    self.target_date = Date.today
    if bank_transfer_item = Item.where(name: '資金移動').first
      self.src_item_id = bank_transfer_item.id
      self.dst_item_id = bank_transfer_item.id
    end
  end

  def transfer!
    raise ActiveRecord::RecordInvalid.new(self) unless self.valid?

    results = []

    ActiveRecord::Base.transaction do
      payment = PaymentHeader.create!(
        user_id: self.user_id,
        payable_on: self.target_date,
        slip_no: SlipNo.get_num,
        corporation_code: self.src_my_account&.corporation_code,
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

      receipt = ReceiptHeader.create!(
        user_id: self.user_id,
        receipt_on: self.target_date,
        corporation_code: self.dst_my_account&.corporation_code,
        my_account_id: self.dst_my_account_id,
        item_id: self.dst_item_id,
        project_id: self.project_id,
        amount: self.amount,
        comment: self.comment,
        no_monthly_report: true
      )

      self.payment_header = payment
      self.receipt_header = receipt

      self.save!
    end

    self
  end

  private

  def my_account_has_corporation_code
    unless src_my_account.my_corporation
      self.errors.add :src_my_account_id, '法人名が未設定です'
    end
    unless dst_my_account.my_corporation
      self.errors.add :dst_my_account_id, '法人名が未設定です'
    end
  end
end
