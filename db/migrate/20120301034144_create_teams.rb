class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.string :name,:null => false
      t.string :cid
      t.integer :teacher_id
      t.timestamps
    end
  end
end
