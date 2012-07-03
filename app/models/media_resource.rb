class MediaResource < ActiveRecord::Base
  has_many   :file_entities,
             :order => 'created_at DESC'

  belongs_to :creator,
             :class_name  => 'User'

  has_many   :media_resources,
             :foreign_key => 'dir_id'

  belongs_to :media_resource,
             :conditions  => {:is_dir => true}

  def self.find_by_path path, collection = MediaResource
    is_dir = path.length == 1 ? false : true
    path_clone = path
    path_seg = collection.where(:name => path_clone.shift, :is_dir => is_dir)
    return path_seg.first if path_clone.blank?
    return path_seg.first if path_seg.blank?
    find_by_path path_clone, path_seg.first.media_resources
  end

  def self.create_by_path path, dir_id = 0
    is_dir = path.length == 1 ? false : true
    path_clone = path
    resource = find_or_create_by_name :name   => path_clone.shift,
                                      :is_dir => is_dir,
                                      :dir_id => dir_id
    return resource if is_dir == false
    create_by_path path_clone, resource.id
  end

  def metadata
    self.is_dir ? dir_metadata : file_metadata
  end

  def latest_entity
    self.file_entities.order('created_at DESC').first
  end

  def latest_attach
    latest_entity.attach
  end

  def path resource = self, input_array = []
    path_ary = input_array
    if resource.dir_id == 0
      return path_ary.map {|r| r.name}.join('/').insert(0, '/')
    end
    parent = MediaResource.find(resource.dir_id)

    path_ary.unshift parent
    path parent, path_ary
  end

  protected

  def file_metadata
    {
      :bytes    => latest_attach.size,
      :rev      => Utils.randstr(8),
      :modified => updated_at,
      :path     => path 
    }
  end

  def dir_metadata
  end
end
