class CreateMediaFolders < ActiveRecord::Migration
  def change
    create_table :media_folders do |t|
      t.string   :name
      t.integer  :media_folder_id,
                 :default => 0

      t.timestamps
    end
  end
end
