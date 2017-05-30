class ReceiptHeader < ActiveRecord::Base
  include Enums::TaxTypeEnum

  belongs_to :user, class_name: 'Casein::AdminUser', foreign_key: 'user_id'
  belongs_to :account
  belongs_to :project
  belongs_to :item
  belongs_to :my_account
  belongs_to :my_corporation, foreign_key: 'corporation_code'
  has_one :receipt_invoice_info, dependent: :destroy

  accepts_nested_attributes_for :receipt_invoice_info

  validates :amount, numericality: {only_integer: true}

  scope :onlymine, -> (user) { user.is_admin? ? all : where(user_id: user) }
  scope :receipt_on_is_not_null, -> { where('receipt_headers.receipt_on IS NOT NULL') }
  scope :left_join_projects, -> {
    joins("LEFT OUTER JOIN projects ON projects.id = receipt_headers.project_id")
  }
  scope :left_join_accounts , -> {
    joins("LEFT OUTER JOIN accounts ON accounts.id = receipt_headers.account_id")
  }
  scope :with_my_account_id, -> (my_account_id) {
    sql = <<-SQL
receipt_headers.my_account_id = :my_account_id OR (receipt_headers.my_account_id IS NULL AND projects.my_account_id = :my_account_id)
    SQL
    where(sql, my_account_id: my_account_id)
  }

  scope :like_search, -> (column, word) { where("#{column} LIKE ?", "%#{word}%") }

  scope :sum_amount, -> { sum(:amount) }

  def duplicate(attrs = {})
    new_receipt = self.dup
    new_receipt.attributes = attrs
    new_receipt.receipt_invoice_info = receipt_invoice_info.dup if receipt_invoice_info
    new_receipt.save
    new_receipt
  end

  class << self
    def duplicate_monthly_data(current_user, target_ids)
      ReceiptHeader.transaction do 
        query = ReceiptHeader.where(id: target_ids)
        query.onlymine(current_user).where.not(receipt_on: nil).each do |receipt|
          receipt.duplicate({
            user_id: current_user.id,
            planned: true,
            monthly_data: true,
            receipt_on: receipt.receipt_on.next_month
          })
        end
      end
    end
  end
end
