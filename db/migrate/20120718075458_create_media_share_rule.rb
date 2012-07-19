class CreateMediaShareRule < ActiveRecord::Migration
  def change
    create_table :media_share_rules do |t|
      t.integer :creator_id
      t.integer :media_resource_id
      t.text    :expression
      t.timestamps
    end
  end
end
