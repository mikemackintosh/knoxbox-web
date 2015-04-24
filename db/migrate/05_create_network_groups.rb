class CreateNetworkGroups < ActiveRecord::Migration
  def up
    create_table :network_groups, :id => false do |t|
      t.references :network_role
      t.string :ldap_group_name
      t.boolean :permit, :default => false      
      t.timestamps
    end
  end

  def down
    drop_table :network_groups
  end
end