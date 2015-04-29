require 'rake'
require 'knoxbox/tasks'
require 'sinatra/activerecord/rake'
require 'knoxbox-web'
require 'easyrsa'

# KnoxBox
KNOXBOX_DIR = ENV['KNOXBOX_DIR'] ||= '/opt/knoxbox/keys'

# Add an admin user
# USER=mmackintosh rock run rake knoxbox:add_admin
namespace :knoxbox  do
  desc "Add user to admin group"
  task :add_admin do
    role = Role.find_or_create_by(role: 'admin')
    user = User.find_by(username: ENV['USER'])
    user.roles << role
    user.save!
   
    print "#{ENV['USER']} added as admin.\n"
  end

# sudo CA_NAME='CN=localhost' rock run rake knoxbox:create_ca
  task :create_ca do
    EasyRSA::Config.from_hash(KnoxBoxWeb::Config.get(:'easyrsa.issuer'))
    easyrsa = EasyRSA::CA.new(ENV['CA_NAME'])
    g = easyrsa.generate

    ca_cert = Pki.find_or_create_by(is: 'ca_cert')
    ca_cert.content = "#{g[:crt]}"
    ca_cert.save

    ca_key = Pki.find_or_create_by(is: 'ca_key')
    ca_key.content = "#{g[:key]}"
    ca_key.save

  end

# IMports existing CA cert and key
  task :import_ca do
    ENV['CA_KEY']
    ENV['CA_CERT']
  end
end

