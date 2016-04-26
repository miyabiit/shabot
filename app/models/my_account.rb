class MyAccount < ActiveRecord::Base
	validates :bank, length: { maximum: 30 }, presence: true
	validates :bank_branch, length: { maximum: 30 }, presence: true
	validates :category, length: { maximum: 10 }
	validates :ac_no, length: { maximum: 20 }, presence: true

  # FIXME enumerize で管理する
	CAT_NAMES =%w(普通 当座 ー)

  # FXME decorator 等に移動
  def bank_label
    "#{bank} #{bank_branch}"
  end
end