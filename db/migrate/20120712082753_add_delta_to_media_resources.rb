class AddDeltaToMediaResources < ActiveRecord::Migration
  def change
  	add_column(:media_resources, :delta, :boolean, :default => true, :null => false)
  end
end
