class Project < ActiveRecord::Base

	validates :name , uniqueness: { scope: [:category] }

  belongs_to :my_account

  scope :order_for_select, -> { order(:name, :category) }
  
	def self.search(search)
		if search
			Project.where(['name LIKE ?', "%#{search}%"])
		else
			Project.all
		end
	end

	def name_and_category
		self.name + ' - ' + self.category
	end
end
