class CreatePki< ActiveRecord::Migration
  def up
    create_table :pki do |t|
      t.string :is
      t.text :content
    end
  end

  def down
    drop_table :pki
  end
end