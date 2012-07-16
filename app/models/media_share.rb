# encoding: utf-8

class MediaShare < ActiveRecord::Base
  belongs_to :media_resource
  belongs_to :creator, :class_name => 'User', :foreign_key => 'creator_id'
  belongs_to :receiver, :class_name => 'User', :foreign_key => 'receiver_id'
  after_create lambda {UserShareTipMessage.create(receiver, "#{creator.name}向您分享了#{media_resource.is_dir? ? '目录' : '文件'}: #{media_resource.name}。")}

  validates  :media_resource, :presence => true
  validates  :creator, :presence => true
  validates  :receiver, :presence => true

  # 给 User 类扩展方法，User类 include 这个 module
  module UserMethods
    def self.included(base)
      base.has_many :received_media_shares, :class_name => 'MediaShare', :foreign_key => :receiver_id
      base.has_many :received_shared_media_resources, :through => :received_media_shares, :source => :media_resource

      base.has_many :created_media_shares, :class_name => 'MediaShare', :foreign_key => :creator_id
      base.has_many :created_shared_media_resources, :through => :created_media_shares, :source => :media_resource

      base.send(:include, InstanceMethods)
    end

    module InstanceMethods
      def shared_res_users
        MediaShare.where("receiver_id = ?", self.id).group("creator_id")
      end

      def shared_res_count(user)
        res = MediaShare.select("count(id) as count").where("receiver_id = ? and creator_id = ?", self.id, user.id).first
        res.count
      end

      def shared_res_by_user(user)
        MediaShare.where("creator_id = ? and receiver_id = ?", user.id, self.id)
      end

    end

  end


  # 给 MediaResource 类扩展方法，MediaResource 类 include 这个 module
  module MediaResourceMethods
    def self.included(base)
      base.has_many :media_shares
      base.has_many :shared_receivers, :through => :media_shares, :source => :receiver

      base.send(:include, InstanceMethods)
    end

    module InstanceMethods
      
      # 判断是否已经分享给该用户
      def shared_to?(user)
        receivers = self.shared_receivers

        if receivers.any?
          receivers.each do |receiver|
            if receiver == user
              return true
            end
          end         
        end

        return false
        
      # 结束 shared_to
      end


      # 取得最上层目录对象
      def toppest_resource(media_resource)
        if media_resource.dir_id == 0
          return media_resource
        else
          toppest_resource(media_resource.dir)
        end
      end
      # 结束 toppest_resource

    end
  end


  # 设置全文索引字段
  define_index do
    # fields
    indexes media_resource.name
    indexes receiver_id
    
    # attributes
    has created_at, updated_at

    set_property :delta => true
  end

end
