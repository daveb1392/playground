class Member < ApplicationRecord
  has_many :orders
  has_many :creations
end
