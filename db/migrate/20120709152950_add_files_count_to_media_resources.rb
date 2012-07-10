class AddFilesCountToMediaResources < ActiveRecord::Migration
  def change
    add_column :media_resources,
               :files_count,
               :integer,
               :default => 0
  end
end
