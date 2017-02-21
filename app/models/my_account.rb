class MyAccount < ActiveRecord::Base
  extend Enumerize
  include Enums::AccountEnum

  validates :bank, length: { maximum: 30 }, presence: true
  validates :bank_branch, length: { maximum: 30 }, presence: true
  validates :category, length: { maximum: 10 }
  validates :ac_no, length: { maximum: 20 }, presence: true

  has_one :bank_account_balance
  belongs_to :account
  belongs_to :my_corporation, foreign_key: 'corporation_code'

  scope :bank_name_order, -> (direction) { order("bank #{direction}, bank_branch #{direction}, category #{direction}, ac_no #{direction}") }
  scope :corporation_code_order, -> (direction) { order("corporation_code #{direction}") }

  # FXME decorator 等に移動
  def bank_label
    "#{bank} #{bank_branch}"
  end

  def ac_no_label
    "#{category} #{ac_no}"
  end

  def bank_long_label
    "#{bank} #{bank_branch} #{category} #{ac_no}"
  end
end
