class Course < ActiveRecord::Base
  belongs_to :teacher

  has_many :course_students
  has_many :students, :through => :course_students

  validates :name, :presence => true
  validates :cid, :uniqueness => { :if => Proc.new { |course| !course.cid.blank? } }
end
