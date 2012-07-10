class RemoveOriginalFileNameFromFileEntity < ActiveRecord::Migration
  def change
    remove_column(:file_entities, :original_file_name)
  end
end
