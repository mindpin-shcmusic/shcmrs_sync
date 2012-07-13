class AddDeltaToMediaShares < ActiveRecord::Migration
  def change
  	add_column(:media_shares, :delta, :boolean, :default => true, :null => false)
  end
end
