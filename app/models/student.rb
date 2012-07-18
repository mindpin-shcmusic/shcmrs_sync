class Student < ActiveRecord::Base
  belongs_to :user
  # --- 校验方法
  validates :real_name, :presence=>true
  validates :sid, :uniqueness => {
    :if => Proc.new { |student| !student.sid.blank? }
  }
  
  validates :real_name, :presence=>true
  validates :sid, :uniqueness => { :if => Proc.new { |student| !student.sid.blank? } }
  
  module UserMethods
    def self.included(base)
      base.has_one :student
      base.send(:include,InstanceMethod)
    end
    
    module InstanceMethod
      def is_student?
        !self.student.blank?
      end
    end
  end
end
