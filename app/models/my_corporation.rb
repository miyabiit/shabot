class MyCorporation < ActiveRecord::Base
  include Concerns::LogicalDelete

  self.primary_key = :code

  validates :code, presence: true, uniqueness: true
  validates :name, presence: true

end
