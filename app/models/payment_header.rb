class PaymentHeader < ActiveRecord::Base
  extend Enumerize

  has_many :payment_parts, dependent: :destroy
  belongs_to :user, class_name: 'Casein::AdminUser', foreign_key: 'user_id'
  belongs_to :account
  belongs_to :my_account
  belongs_to :project

  accepts_nested_attributes_for :payment_parts, allow_destroy: true

  enumerize :fee_who_paid, in: ["先方負担", "自社負担"]
  enumerize :org_name, in: %w(シャロンテック 聚楽荘 JAM ベルク ブルームコンサルティング その他)

  MAX_PARTS_LENGTH = 5

  validates :comment, length: { maximum: 400 }
  validates :payment_parts, length: { maximum: MAX_PARTS_LENGTH }

  scope :planned_only, -> { where(planned: true) }
  scope :result_only , -> { where(planned: false) }
  scope :payable_on_is_not_null, -> { where('payment_headers.payable_on IS NOT NULL') }

  def self.search(slip_no = nil)
    if slip_no
      PaymentHeader.where(['slip_no like ?', "%#{slip_no}%"])
    else
      PaymentHeader.all
    end
  end

  def self.search_account(account_name)
    if account_name
      PaymentHeader.joins(:account).merge(Account.where(['name like ?', "%#{account_name}%"]))
    else
      PaymentHeader.all
    end
  end

  def self.onlymine(user)
    if user.is_admin?
      PaymentHeader.all
    else
      PaymentHeader.where(user_id: user.id)
    end
  end
  
  def total
    ttl = 0
    self.payment_parts.each do |part|
      ttl += part.amount.to_i
    end
    ttl
  end

  # FIXME: decorator等で処理
  def my_bank_label
    my_account_model = self.my_account || self.project.try(:my_account)
    return "" unless my_account_model
    my_account_model.bank
  end

  def my_bank_branch_and_number_label
    my_account_model = self.my_account || self.project.try(:my_account)
    return "" unless my_account_model
    "#{my_account_model.bank_branch} #{my_account_model.category} #{my_account_model.ac_no}" 
  end
end

