class PublicResource < ActiveRecord::Base
  belongs_to :file_entity
  belongs_to :media_resource
  belongs_to :creator, :class_name  => 'User', :foreign_key => 'creator_id'


  def self.upload_by_user(user, file)
    file_entity = FileEntity.new(:attach => file)
    public_resource = PublicResource.create(
      :creator => user,
      :file_entity => file_entity,
      :name => file_entity.attach_file_name,
      :kind => 'UPLOAD'
    )
  end


  # 给 User 类扩展方法，User类 include 这个 module
  module UserMethods
    def self.included(base)
      base.has_many :shared_public_resources, 
                    :class_name => 'PublicResource', :foreign_key => :creator_id,
                    :conditions => lambda { "kind = 'LINK'" }

      base.has_many :uploaded_public_resources, 
                    :class_name => 'PublicResource', :foreign_key => :creator_id,
                    :conditions => lambda { "kind = 'UPLOAD'" }

 
      base.send(:include, InstanceMethods)
    end

    module InstanceMethods
    
    end

  end
  # 结束 UserMethods


  # 给 MediaResource 类扩展方法，MediaResource 类 include 这个 module
  module MediaResourceMethods
    def self.included(base)
      base.has_one :shared_public_resource,
                   :class_name  => 'MediaResource', :foreign_key => 'media_resource_id'

      base.send(:include, InstanceMethods)
    end

    module InstanceMethods

      # 分享到公共资源
      def share_public
        if self.is_public?
          return ''
        end

        public_resource = PublicResource.create(
          :creator => self.creator,
          :media_resource => self,
          :name => self.name,
          :kind => 'LINK'
        )

        public_resource.id
      end
      # 结束 put_public


      # 判断是否添加到公共资源库
      def is_public?
        PublicResource.where(:media_resource_id => self.id).exists?
      end
      # 结束判断 is_public

    end

  end

  # 结束 MediaResourceMethods


  # 设置全文索引字段
  define_index do
    # fields
    indexes name, :sortable => true
    indexes creator_id
    
    # attributes
    has kind, created_at, updated_at

    set_property :delta => true
  end
  
end
