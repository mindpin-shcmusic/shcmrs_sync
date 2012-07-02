class CreateMediaFiles < ActiveRecord::Migration
  def change
    create_table :media_files do |t|
      t.integer  :file_entity_id
      t.integer  :media_folder_id,
                 :default => 0

      t.timestamps
    end
  end
end
