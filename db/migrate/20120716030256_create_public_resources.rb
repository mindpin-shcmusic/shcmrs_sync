class CreatePublicResources < ActiveRecord::Migration
  def change
    create_table :public_resources do |t|
      t.integer   :creator_id
      t.integer   :media_resource_id
      t.integer   :file_entity_id
      t.string    :kind

      t.timestamps
    end
  end
end
