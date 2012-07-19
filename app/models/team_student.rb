class TeamStudent < ActiveRecord::Base
  belongs_to :team
  belongs_to :student
  
  validates :team, :student, :presence=>true
end
