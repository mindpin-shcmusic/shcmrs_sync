class CourseStudent < ActiveRecord::Base
  belongs_to :course
  belongs_to :student

  validates :course, :student, :presence => true
end