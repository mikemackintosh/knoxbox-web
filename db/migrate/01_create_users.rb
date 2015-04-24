class CreateUsers < ActiveRecord::Migration
  def up
    create_table :users do |t|
      t.string  :username
      t.string  :email
      t.string  :password_digest
      t.string  :method, :default => 'password'
      t.string  :given_name
      t.string  :family_name
      t.string  :picture
      t.string  :secret
      t.text    :cert
      t.text    :key
      t.boolean :activated, :default => false
      t.timestamps
    end
  end

  def down
    drop_table :users
  end
end