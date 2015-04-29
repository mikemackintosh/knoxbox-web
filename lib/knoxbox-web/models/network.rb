class Network < ActiveRecord::Base
   self.table_name = 'network_access_list'
   has_and_belongs_to_many :network_roles
end