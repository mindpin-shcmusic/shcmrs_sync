class AddDeltaToPublicResource < ActiveRecord::Migration
  def change
  	add_column(:public_resources, :delta, :boolean, :default => true, :null => false)
  end
end
