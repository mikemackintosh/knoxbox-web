class CreateNetworkRoles < ActiveRecord::Migration
  def up
    create_table :network_roles do |t|
      t.string  :name
      t.text    :description
      t.timestamps
    end
  end

  def down
    drop_table :network_roles
  end
end