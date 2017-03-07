class LinkedService < ActiveRecord::Base
  belongs_to :my_corporation, foreign_key: 'corporation_code', inverse_of: :linked_services

  def name
    raise 'Must be override "name" method!'
  end
end
