class PaymentHeader < ActiveRecord::Base
  extend Enumerize

  has_many :payment_parts, dependent: :destroy
  belongs_to :user, class_name: 'Casein::AdminUser', foreign_key: 'user_id'
  belongs_to :account
  belongs_to :my_account
  belongs_to :project
  belongs_to :process_user, class_name: 'Casein::AdminUser', foreign_key: 'process_user_id'

  accepts_nested_attributes_for :payment_parts, allow_destroy: true

  enumerize :fee_who_paid, in: ["先方負担", "自社負担"]
  enumerize :org_name, in: %w(シャロンテック 聚楽荘 JAM ベルク ブルームコンサルティング その他)

  MAX_PARTS_LENGTH = 5

  validates :comment, length: { maximum: 400 }
  validates :payment_parts, length: { maximum: MAX_PARTS_LENGTH }

  validate :validate_on_processed

  scope :planned_only, -> { where(planned: true) }
  scope :result_only , -> { where(planned: false) }
  scope :payable_on_is_not_null, -> { where('payment_headers.payable_on IS NOT NULL') }
  scope :search, -> (slip_no) {
    if slip_no
      where(['slip_no like ?', "%#{slip_no}%"])
    else
      all
    end
  }
  scope :search_account, -> (account_name) {
    if account_name
      joins(:account).merge(Account.where(['name like ?', "%#{account_name}%"]))
    else
      all
    end
  }
  scope :onlymine, -> (user) {
    if user.is_admin?
      all
    else
      where(user_id: user.id)
    end
  }

  def total
    payment_parts.sum(:amount)
  end

  # 処理済時に処理済フラグの属性以外を更新不可にする
  def validate_on_processed
    if processed?
      if (changed? || payment_parts.any?{|p| p.changed? || p.marked_for_destruction?}) && !processed_changed?
        errors.add :base, '処理済の支払い申請は変更できません'
        return false
      end
    end
  end

  def clear_processed
    self.processed = false
    self.process_user_id = nil
    self.process_date = nil
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

