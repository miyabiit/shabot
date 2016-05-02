class PaymentHeader < ActiveRecord::Base
	has_many :payment_parts
  belongs_to :user, class_name: 'Casein::AdminUser', foreign_key: 'user_id'
	belongs_to :account
  belongs_to :my_account
  belongs_to :project
  
	MAX_PARTS_LENGTH = 5
  # FIXME enumerize で管理する
	WHO_PAY = ["先方負担", "自社負担"]
	ORG_NAMES = %w(シャロンテック 聚楽荘 JAM ベルク ブルームコンサルティング その他)
	validates :comment, length: { maximum: 400 }
	validates :payment_parts, length: { maximum: MAX_PARTS_LENGTH }

  scope :planned_only, -> { where(planned: true) }
  scope :result_only , -> { where(planned: false) }

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

