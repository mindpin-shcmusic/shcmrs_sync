class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|
      t.string :name,:null => false
      t.string :cid
      t.string :department
      t.string :location
      t.integer :teacher_id
      t.text :desc
      t.timestamps
    end
  end
end
