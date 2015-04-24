class CreateLogs < ActiveRecord::Migration
  def up
    create_table :logs do |t|
      t.string :message
      t.string :remote_host
      t.string :cn
      t.string :instance_id
      t.timestamps
    end
  end

  def down
    drop_table :logs
  end
end