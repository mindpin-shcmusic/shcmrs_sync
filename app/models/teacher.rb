class Teacher < ActiveRecord::Base
  belongs_to :user
  
  validates :real_name, :presence => true
  validates :tid, :uniqueness => { :if => Proc.new { |teacher| !teacher.tid.blank? } }
  
  module UserMethods
    def self.included(base)
      base.has_one :teacher
      base.send(:include,InstanceMethod)
      base.send(:extend,ClassMethod)
      base.scope  :student_role,
        :joins=>"inner join students on students.user_id = users.id"
      base.scope  :teacher_role,
        :joins=>"inner join teachers on teachers.user_id = users.id"
    end
    
    module InstanceMethod
      def is_teacher?
        !self.teacher.blank?
      end
      
      def real_name
        self.teacher.real_name if is_teacher?
        self.student.real_name if is_student?
        self.name
      end
    end
    
    module ClassMethod
      def no_role
        self.all-self.student_role-self.teacher_role
      end
    end
    
  end
end
