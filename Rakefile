require 'rake'
require 'knoxbox/tasks'
require 'sinatra/activerecord/rake'
require 'knoxbox-web'

# Add an admin user
namespace :knoxbox  do
  desc "Add user to admin group"
  task :add_admin do
    role = Role.find_or_create_by(role: 'admin')
    user = User.find_by(username: ENV['USER'])
    user.roles << role
    user.save!
   
    print "#{ENV['USER']} added as admin.\n"
  end
end