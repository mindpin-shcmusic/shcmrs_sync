class MediaResource < ActiveRecord::Base

  # --------

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

  # --------

  before_create :create_fileops_time
  def create_fileops_time
    self.fileops_time = Time.now
  end

  # --------

  default_scope where(:is_removed => false).order('is_dir DESC', 'name ASC')
  scope :removed, where(:is_removed => true)
  scope :root_res, where(:dir_id => 0)

  # 根据传入的资源路径字符串，查找一个资源对象
  # 传入的路径类似 /foo/bar/hello/test.txt
  # 或者 /foo/bar/hello/world
  # 找到的资源对象，可能是一个文件资源，也可能是一个文件夹资源
  def self.get_by_path(resource_path)
    names = self._names_of_path(resource_path)

    collect = self.root_res
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
    file_name = self._names_of_path(resource_path)[-1]

    # 传入的是 /北极熊/企鹅/西瓜.jpg
    # 则
    # file_name: "西瓜.jpg"
    # dirs ['北极熊', '企鹅']

    collect = self._mkdirs_for_file(resource_path)

    resource = collect.find_or_initialize_by_name(file_name)
    resource._remove_children

    resource.is_dir = false
    resource.is_removed = false
    resource.file_entity = FileEntity.new({
      :attach => file,
      :original_file_name => file_name
    })

    resource.save
  end

  def self.create_folder_by_path(resource_path)
    self._mkdirs_for_path(resource_path)
  end

  def remove
    self._remove_children

    self.update_attributes :is_removed   => true,
                           :fileops_time => Time.now
  end

    def _remove_children
      self.media_resources.each {|resource|
        resource.remove
      } if self.is_dir
    end

  # -----------

  def metadata(options = {:list => true})
    is_dir ? dir_metadata(options) : file_metadata
  end

  def dir_metadata(options = {})
    contents = options[:list] ? self.media_resources.map{|mr| mr.metadata(:list=>false)} : [] 

    {
      :bytes    => 0,
      :path     => self.path,
      :is_dir   => false,
      :contents => contents
    }
  end

  def file_metadata
    {
      :bytes     => self.attach.size,
      :path      => self.path,
      :is_dir    => false,
      # :rev       => randstr(8),
      # :modified  => updated_at,
      :mime_type => self.attach.content_type
    }
  end

  def attach
    file_entity && file_entity.attach
  end

  def path
    if(self.dir_id == 0)
      return "/#{self.name}"
    end

    return "#{self.dir.path}/#{self.name}"
  end


  # def self.delta(cursor = 0, limit = 100)
  #   delta    = self.where('id > ?', cursor).limit(limit)
  #   entries  = delta.map {|r| [r.path, r.metadata(:list => false)]}
  #   has_more = !delta.blank? && (self.last.id > delta.last.id)

  #   {
  #     :entries  => entries,
  #     :reset    => false,
  #     :cursor   => delta.last && delta.last.id,
  #     :has_more => has_more
  #   }
  # end

  # def web_path
  #   '/file' + path
  # end


  private

  # 根据传入的 resource_path 划分出涉及到的资源名称数组
  def self._names_of_path(resource_path) 
    resource_path.sub('/', '').split('/')
  end

  # 根据传入的 resource_path 逐层创建他的上层文件夹
  # 传入的是 北极熊/企鹅/西瓜.jpg
  # 则
  # dir_names: ["北极熊", "企鹅"] (不包括 西瓜.jpg)
  # 逐层地创建目录资源
  def self._mkdirs_for_file(resource_path)
    dir_names = self._names_of_path(resource_path)[0...-1] # 只创建到上层目录

    collect = MediaResource.root_res

    dir_names.each {|dir_name|
      dir_resource = collect.find_or_create_by_name_and_is_dir(dir_name, true)
      collect = dir_resource.media_resources
    }

    return collect
  end

  # 根据传入的 resource_path 逐层创建文件夹
  # 传入的是 北极熊/企鹅/图片
  # 则
  # dir_names: ["北极熊", "企鹅", "图片"] 
  # 逐层地创建目录资源
  def self._mkdirs_for_path(resource_path)
    dir_names = self._names_of_path(resource_path)

    collect = MediaResource.root_res

    dir_resource = nil
    dir_names.each {|dir_name|
      dir_resource = collect.find_or_create_by_name_and_is_dir(dir_name, true)
      collect = dir_resource.media_resources
    }

    return dir_resource
  end

end
