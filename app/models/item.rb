class Item < ActiveRecord::Base
  include Concerns::LogicalDelete

  validates :name, uniqueness: true

  def self.search(search)
    if search
      Item.where(['name LIKE ?', "%#{search}%"])
    else
      Item.all
    end
  end
  
end
