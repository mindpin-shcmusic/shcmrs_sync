class MediaResource < ActiveRecord::Base
  has_many   :file_entities,
             :order => 'created_at DESC'

  belongs_to :creator,
             :class_name  => 'User'

  has_many   :media_resources,
             :foreign_key => 'dir_id'

  belongs_to :media_resource,
             :conditions  => {:is_dir => true}

  def self.bla path, collection = MediaResource.where('')
    return collection if path.blank?
    is_dir = path.length == 1 ? false : true
    path_clone = path.clone
    path_seg = collection.where(:name => path_clone.shift, :is_dir => is_dir).first
    return path_seg if path_seg.nil?
    bla path_clone, path_seg.media_resources
  end
end
