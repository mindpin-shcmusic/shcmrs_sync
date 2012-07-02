class CreateFileEntities < ActiveRecord::Migration
  def change
    create_table :file_entities do |t|
      t.string   :attachment_file_name
      t.string   :attachment_content_type
      t.string   :attachment_file_size
      t.string   :attachment_updated_at

      t.string   :original_file_name

      t.integer  :media_file_id

      t.string   :md5

      t.boolean  :merged,
                 :default => false

      t.timestamps
    end
  end
end
