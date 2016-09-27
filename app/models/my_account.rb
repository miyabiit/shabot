class MyAccount < ActiveRecord::Base
  extend Enumerize
  include Enums::AccountEnum

  validates :bank, length: { maximum: 30 }, presence: true
  validates :bank_branch, length: { maximum: 30 }, presence: true
  validates :category, length: { maximum: 10 }
  validates :ac_no, length: { maximum: 20 }, presence: true

  has_one :bank_account_balance

  scope :bank_name_order, -> (direction) { order("bank #{direction}, bank_branch #{direction}, category #{direction}, ac_no #{direction}") }

  # FXME decorator 等に移動
  def bank_label
    "#{bank} #{bank_branch}"
  end

  def bank_long_label
    "#{bank} #{bank_branch} #{category} #{ac_no}"
  end
end
