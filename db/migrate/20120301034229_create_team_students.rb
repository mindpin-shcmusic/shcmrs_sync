class CreateTeamStudents < ActiveRecord::Migration
  def change
    create_table :team_students do |t|
      t.integer :team_id
      t.integer :student_id
      t.timestamps
    end
  end
end
