class CreateFileEntitiesAndMediaResources < ActiveRecord::Migration
  def change

    create_table :file_entities do |t|

      t.string   :attach_file_name
      t.string   :attach_content_type
      t.integer  :attach_file_size
      t.datetime :attach_updated_at

      t.string   :original_file_name
      t.string   :md5

      t.boolean  :merged, :default => false

      t.timestamps
    end

    add_index :file_entities, :md5

    # -----------

    create_table :media_resources do |t|
      t.integer :file_entity_id

      t.string  :name
      t.boolean :is_dir, :default => false

      t.integer :dir_id, :default => 0
      t.integer :creator_id
      
      
      t.timestamps
    end

    add_index :media_resources, :file_entity_id
    add_index :media_resources, :dir_id
    add_index :media_resources, :creator_id
    add_index :media_resources, :name

  end
end
