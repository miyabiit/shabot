class ReceiptHeader < ActiveRecord::Base
  belongs_to :user, class_name: 'Casein::AdminUser', foreign_key: 'user_id'
  belongs_to :account
  belongs_to :project
  belongs_to :item
  belongs_to :my_account

  validates :amount, numericality: {only_integer: true, greater_than_or_equal_to: 0}

  scope :onlymine, -> (user) { user.is_admin? ? all : where(user_id: user) }
end
