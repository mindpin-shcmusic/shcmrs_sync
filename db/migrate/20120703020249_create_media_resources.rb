class CreateMediaResources < ActiveRecord::Migration
  def change
    create_table :media_resources do |t|
      t.string   :name
      t.boolean  :is_dir
      t.integer  :dir_id
      t.integer  :creator_id

      t.timestamps
    end
  end
end
