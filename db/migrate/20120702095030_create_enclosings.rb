class CreateEnclosings < ActiveRecord::Migration
  def change
    create_table :enclosings do |t|
      t.integer  :parent_folder_id
      t.integer  :file_folder_id
    end
  end
end
