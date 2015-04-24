class CreateTrustedIps < ActiveRecord::Migration
  def up
    create_table :trusted_ips, :id => false do |t|
      t.references  :user
      t.string      :ip
      t.string      :hostname
      t.integer     :access_count, :default => 0
      t.timestamps
    end
  end

  def down
    drop_table :trusted_ips
  end
end