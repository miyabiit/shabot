class PaymentPart < ActiveRecord::Base
	belongs_to :payment_header
	belongs_to :item
  
	#todo マイナスもあるし、新規追加の時に０セットされるため役にたたない
	#validates :amount, numericality: { only_integer: true, greater_than: 0 }

end
