class PaymentHeader < ActiveRecord::Base
  extend Enumerize

  has_many :payment_parts, dependent: :destroy
  belongs_to :user, class_name: 'Casein::AdminUser', foreign_key: 'user_id'
  belongs_to :account
  belongs_to :my_account
  belongs_to :project
  belongs_to :process_user, class_name: 'Casein::AdminUser', foreign_key: 'process_user_id'
  belongs_to :my_corporation, foreign_key: 'corporation_code'

  accepts_nested_attributes_for :payment_parts, allow_destroy: true

  enumerize :fee_who_paid, in: %W(先方負担 自社負担)
  enumerize :payment_type, in: %W(eb withdrawal desk)

  MAX_PARTS_LENGTH = 5

  validates :comment, length: { maximum: 400 }
  validates :payment_parts, length: { maximum: MAX_PARTS_LENGTH, message: "は %{count} つまでにしてください" }

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
  scope :left_join_projects, -> {
    joins("LEFT OUTER JOIN projects ON projects.id = payment_headers.project_id")
  }
  scope :left_join_accounts , -> {
    joins("LEFT OUTER JOIN accounts ON accounts.id = payment_headers.account_id")
  }
  scope :with_my_account_id, -> (my_account_id) {
    sql = <<-SQL
payment_headers.my_account_id = :my_account_id OR (payment_headers.my_account_id IS NULL AND projects.my_account_id = :my_account_id)
    SQL
    where(sql, my_account_id: my_account_id)
  }
  scope :payable_on_from_to, -> (from, to) {
    form = Date.new(1999, 1, 1) if from.blank?
    to = Date.new(3000, 1, 1) if to.blank?
    where(payable_on: from..to)
  }

  scope :sum_amount, -> { joins(:payment_parts).sum('payment_parts.amount') }

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

  def duplicate(attrs = {})
    new_payment = self.dup
    new_payment.slip_no = SlipNo.get_num
    new_payment.clear_processed
    new_payment.attributes = attrs
    if new_payment.save
      self.payment_parts.each do |part|
        new_part = part.dup
        new_payment.payment_parts << new_part
      end
    end
    new_payment
  end

  class << self
    def duplicate_monthly_data(current_user, target_ids)
      PaymentHeader.transaction do 
        query = PaymentHeader.where(id: target_ids)
        query.onlymine(current_user).where.not(payable_on: nil).each do |payment|
          payment.duplicate({
            user_id: current_user.id,
            planned: true,
            monthly_data: true,
            payable_on: payment.payable_on.next_month
          })
        end
      end
    end
  end

end

