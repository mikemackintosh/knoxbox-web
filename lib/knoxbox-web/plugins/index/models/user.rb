require 'bcrypt'
class User < ActiveRecord::Base
  validates :username, :given_name, :family_name, :presence => true
  validates_uniqueness_of :username
  has_and_belongs_to_many :roles
  has_secure_password

  def is_admin?
    has_role('admin')
  end

  def has_role?(role_id)
    roles.where(:role => role_id).first != nil
  end

  def to_h
    hash = {}
    instance_variables.each {|var| hash[var.to_s.delete("@")] = instance_variable_get(var) }
    hash
  end
end