class AddNameToPublicResource < ActiveRecord::Migration
  def change
  	add_column(:public_resources, :name, :string)
  end
end
