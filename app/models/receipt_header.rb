class ReceiptHeader < ActiveRecord::Base
  belongs_to :user, class_name: 'Casein::AdminUser', foreign_key: 'user_id'
  belongs_to :account
  belongs_to :project
  belongs_to :item
  belongs_to :my_account

  validates :amount, numericality: {only_integer: true}

  scope :onlymine, -> (user) { user.is_admin? ? all : where(user_id: user) }
  scope :receipt_on_is_not_null, -> { where('receipt_headers.receipt_on IS NOT NULL') }

end
