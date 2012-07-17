class AddFileopsTimeAndIsRemovedToMediaResources < ActiveRecord::Migration
  def change
    add_column :media_resources,
               :fileops_time,
               :datetime

    add_column :media_resources,
               :is_removed,
               :boolean,
               :default => false

    add_index  :media_resources,
               :fileops_time
  end
end
