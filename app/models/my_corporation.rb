class MyCorporation < ActiveRecord::Base
  include Concerns::LogicalDelete

  self.primary_key = :code

  validates :code, presence: true, uniqueness: true
  validates :name, presence: true

  has_many :linked_services, foreign_key: 'corporation_code', inverse_of: :my_corporation, dependent: :destroy

  accepts_nested_attributes_for :linked_services
end
