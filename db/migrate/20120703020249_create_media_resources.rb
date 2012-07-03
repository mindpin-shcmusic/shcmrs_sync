class CreateMediaResources < ActiveRecord::Migration
  def change
    create_table :media_resources do |t|
      t.string   :name
      t.boolean  :is_dir,
                 :default => false

      t.integer  :dir_id,
                 :default => 0

      t.integer  :creator_id

      t.timestamps
    end
  end
end
