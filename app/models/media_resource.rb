class MediaResource < ActiveRecord::Base
  belongs_to :file_entity

  belongs_to :creator,
             :class_name  => 'User',
             :foreign_key => 'creator_id'

  has_many   :media_resources,
             :foreign_key => 'dir_id'

  belongs_to :dir,
             :class_name  => 'MediaResource',
             :foreign_key => 'dir_id',
             :conditions  => {:is_dir => true}

  validates  :name,
             :uniqueness  => {
               :case_sensitive => false,
               :scope          => :dir_id
             }

  before_create :create_fileops_time

  default_scope where(:is_removed => false).order('is_dir desc', 'name asc')
  scope      :removed,
             where(:is_removed => true)

  def remove
    self.update_attributes :is_removed   => true,
                           :fileops_time => Time.now

    self.media_resources.each {|resource|
      resource.remove
    } if self.is_dir

    self
  end

  def web_path
    '/file' + path
  end

  # 根据传入的资源路径字符串，查找一个资源对象
  # 传入的路径类似 /hello/test.txt
  # 或者 /hello/world
  # 找到的资源对象，可能是一个文件资源，也可能是一个文件夹资源
  def self.get_by_path(resource_path)
    names = get_names_from_path resource_path

    collect = MediaResource
    resource = nil

    names.each {|name|
      resource = collect.find_by_name(name)
      return nil if resource.blank?
      collect = resource.media_resources
    }

    return resource
  end

  # 根据传入的资源路径字符串以及文件对象，创建一个文件资源
  # 传入的路径类似 /hello/test.txt
  # 创建文件资源的过程中，关联创建文件夹资源
  def self.put_file_by_path(resource_path, file)
    file_name = get_names_from_path(resource_path)[-1]

    # 传入的是 北极熊/企鹅/西瓜.jpg
    # 则
    # file_name: "西瓜.jpg"



    collect = _mkdirs(resource_path)[0]

    resource = collect.find_or_initialize_by_name_and_is_dir(file_name, false)

    resource.file_entity = FileEntity.new({
      :attach => file,
      :original_file_name => file_name
    })

    resource.save
  end

  # 逐层创建文件夹资源（如果不存在），并返回最后一个文件夹资源 或者 MediaResource 类对象
  def self.create_folder_from_path(resource_path)
    dir_resource = _mkdirs(resource_path)[1]

    return dir_resource
  end

  def self._mkdirs(resource_path)
    dir_names = get_names_from_path(resource_path)

    return dir_names.reduce([MediaResource]) {|memo, dir_name|
      dir = memo[0].find_or_create_by_name_and_is_dir(dir_name, true)
      [dir.media_resources, dir]
    }
  end

  # ------------
  # 下面的代码还没动

  def metadata(options = {:list => true})
    is_dir ? dir_metadata(options) : file_metadata
  end

  def attach
    file_entity && file_entity.attach
  end

  def path(resource = self, input_array = [])
    path_ary = input_array

    if resource.dir_id == 0
      path_ary << self.name
      return path_ary.join('/').insert(0, '/')
    end

    parent = MediaResource.find(resource.dir_id)

    path parent,
         path_ary.unshift(parent.name)
  end


  def self.delta(cursor = 0, limit = 100)
    delta    = self.where('id > ?', cursor).limit(limit)
    entries  = delta.map {|r| [r.path, r.metadata(:list => false)]}
    has_more = !delta.blank? && (self.last.id > delta.last.id)

    {
      :entries  => entries,
      :reset    => false,
      :cursor   => delta.last && delta.last.id,
      :has_more => has_more
    }
  end

  private

  def self.get_names_from_path path 
    path.sub('/', '').split('/')
  end

  def file_metadata
    base_metadata.merge({
      :rev       => randstr(8),
      :modified  => updated_at,
      :mime_type => attach.content_type
    })
  end

  def dir_metadata(options = {})
    options[:list] ?

    base_metadata.merge(:contents => media_resources.map {|r|
      r.is_dir ? r.send(:base_metadata) : r.metadata
    }) :

    base_metadata
  end

  def base_metadata
    {
      :bytes    => is_dir ? 0 : attach.size,
      :path     => path,
      :is_dir   => is_dir
    }
  end

  def create_fileops_time
    self.fileops_time = Time.now
  end
end
