class LinkedService < ActiveRecord::Base
  belongs_to :my_corporation, foreign_key: 'corporation_code'
end
