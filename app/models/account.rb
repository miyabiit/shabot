class Account < ActiveRecord::Base
  extend Enumerize
  include Enums::AccountEnum
  include Concerns::LogicalDelete

  has_many :payment_headers
  
  validates :name, uniqueness: true
  validates :name, length: { maximum: 30 }
  validates :bank, length: { maximum: 30 }
  validates :bank_branch, length: { maximum: 30 }
  validates :category, length: { maximum: 10 }
  validates :ac_no, length: { maximum: 20 }

  scope :except_my_group, -> { where.not(my_group: true) }

  def self.search(search)
    if search
      Account.where(['name LIKE ?', "%#{search}%"])
    else
      Account.all
    end
  end

  # FXME decorator 等に移動
  def bank_label
    "#{bank} #{bank_branch}"
  end

  def branch_long_label
    "#{bank_branch} #{category} #{ac_no}"
  end
end
