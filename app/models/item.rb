class Item < ActiveRecord::Base

  validates :name, uniqueness: true

  def self.search(search)
    if search
      Item.where(['name LIKE ?', "%#{search}%"])
    else
      Item.all
    end
  end
  
end
