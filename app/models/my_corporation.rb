class MyCorporation < ActiveRecord::Base
  self.primary_key = :code

  validates :code, presence: true, uniqueness: true
  validates :name, presence: true

end
