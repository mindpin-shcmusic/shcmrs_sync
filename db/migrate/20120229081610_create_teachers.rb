class CreateTeachers < ActiveRecord::Migration
  def change
    create_table :teachers do |t|
      t.string :real_name,:null => false
      t.string :tid
      t.integer :user_id
      t.timestamps
    end
  end
end
