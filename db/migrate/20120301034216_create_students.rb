class CreateStudents < ActiveRecord::Migration
  def change
    create_table :students do |t|
      t.string :real_name,:null => false
      t.string :sid
      t.integer :user_id
      t.timestamps
    end
  end
end
