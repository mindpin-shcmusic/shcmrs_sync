class AddVideoEncodeStatusColumnToFileEntity < ActiveRecord::Migration
  def change
    add_column :file_entities, :video_encode_status, :string
  end
end
