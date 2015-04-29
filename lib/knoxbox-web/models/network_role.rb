class NetworkRole < ActiveRecord::Base
  has_and_belongs_to_many :networks
end