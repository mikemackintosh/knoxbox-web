class CreateNetworkAccessList < ActiveRecord::Migration
  def up
    create_table :network_access_list, :id => false do |t|
      t.references :network_role
      t.string :address
      t.string :port
      t.string :protocol
      t.boolean :permit, :default => false      
      t.timestamps
    end
  end

  def down
    drop_table :network_access_list
  end
end