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
               :scope     => [:dir_id, :creator_id]
             }

  validates  :creator,
             :presence    => true

  # --------

  before_create :create_fileops_time
  def create_fileops_time
    self.fileops_time = Time.now
  end

  before_create :update_parent_dirs_files_count
  def update_parent_dirs_files_count
    return true if self.is_dir?

    parent_dir = self.dir
    while !parent_dir.blank? do
      parent_dir.increment!(:files_count, 1)
      parent_dir = parent_dir.dir
    end
    return true
  end

  # --------

  default_scope where(:is_removed => false)
  scope :removed, where(:is_removed => true)
  scope :root_res, where(:dir_id => 0)
  scope :ops_order, order('fileops_time ASC')
  scope :web_order, order('is_dir DESC, name ASC')

  def is_file?
    !is_dir?
  end

  # 根据传入的资源路径字符串，查找一个资源对象
  # 传入的路径类似 /foo/bar/hello/test.txt
  # 或者 /foo/bar/hello/world
  # 找到的资源对象，可能是一个文件资源，也可能是一个文件夹资源
  def self.get(creator, resource_path)
    names = self.split_path(resource_path)

    collect = creator.media_resources.root_res
    resource = nil

    names.each {|name|
      resource = collect.find_by_name(name)
      return nil if resource.blank?
      collect = resource.media_resources
    }

    return resource
  rescue InvalidPathError
    return nil
  end

  def self.put_unmerged(creator, resource_path, file_entity)
    self._put(creator, resource_path, file_entity)
  end

  def self.put(creator, resource_path, file)
    raise NotAssignCreatorError if creator.blank?
    raise FileEmptyError if file.blank?

    file_entity = FileEntity.new(:attach => file, :merged => true)
    self._put(creator, resource_path, file_entity)
  end

  # 根据传入的资源路径字符串以及文件对象，创建一个文件资源
  # 传入的路径类似 /hello/test.txt
  # 创建文件资源的过程中，关联创建文件夹资源
  def self._put(creator, resource_path, file_entity)
    with_exclusive_scope do
      file_name = self.split_path(resource_path)[-1]
      dir_names = self.split_path(resource_path)[0...-1] # 只创建到上层目录

      collect = _mkdirs_by_names(creator, dir_names).media_resources

      resource = collect.find_or_initialize_by_name_and_creator_id(file_name, creator.id)
      resource._remove_children!
      resource.update_attributes(
        :is_dir      => false,
        :is_removed  => false,
        :file_entity => file_entity
      )
    end
  end

  def self.create_folder(creator, resource_path)
    raise RepeatedlyCreateFolderError if !self.get(creator, resource_path).blank?

    with_exclusive_scope do
      dir_names = self.split_path(resource_path)
      return _mkdirs_by_names(creator, dir_names)
    end
  rescue InvalidPathError
    return nil
  end

  def remove
    self._remove_children!

    self.update_attributes :is_removed   => true,
                           :fileops_time => Time.now

    if self.is_file?
      parent_dir = self.dir
      while !parent_dir.blank? do
        parent_dir.decrement!(:files_count, 1)
        parent_dir = parent_dir.dir
      end
    end
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
      :is_dir   => true,
      :contents => contents
    }
  end

  def file_metadata
    bytes = self.attach.blank? ? 0 : self.attach.size
    bytes ||= 0
    
    {
      :bytes     => bytes,
      :path      => self.path,
      :is_dir    => false,
      :mime_type => self.attach.blank? ? 'application/octet-stream' : self.attach.content_type
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

  def self.delta(creator, cursor, limit = 100)
    with_exclusive_scope do
      delta_media_resources = creator.media_resources.where('fileops_time > ?', cursor || 0).limit(limit)

      if delta_media_resources.blank?
        new_cursor = cursor
        has_more   = false
      else
        last_fileops_time = delta_media_resources.last.fileops_time
        new_cursor = last_fileops_time
        has_more   = last_fileops_time < MediaResource.last.fileops_time
      end

      entries = delta_media_resources.map do |r|
        [r.path, r.is_removed? ? nil : r.metadata(:list => false)]
      end

      return {
        :entries  => entries,
        :reset    => false,
        :cursor   => new_cursor,
        :has_more => has_more
      }
    end
  end

  private
    # 根据传入的 resource_path 划分出涉及到的资源名称数组
    def self.split_path(resource_path) 
      raise InvalidPathError if resource_path.blank?
      raise InvalidPathError if resource_path[0...1] != '/'
      raise InvalidPathError if resource_path == '/'
      raise InvalidPathError if resource_path.match /\/{2,}/
      raise InvalidPathError if resource_path.include?('\\')

      resource_path.sub('/', '').split('/')
    end

  public

    def self._mkdirs_by_names(creator, dir_names)
      collect = creator.media_resources.root_res
      dir_resource = MediaResource::RootDir

      dir_names.each {|dir_name|
        dir_resource = collect.find_or_initialize_by_name_and_creator_id(dir_name, creator.id)
        dir_resource._change_to_unremoved_dir!
        collect = dir_resource.media_resources
      }

      return dir_resource
    end

    def _change_to_unremoved_dir!
      self.is_removed = false if self.is_removed?
      self.is_dir = true if self.is_file?
      self.save
    end

    def _remove_children!
      self.media_resources.each {|resource|
        resource.remove
      } if self.is_dir
    end

  class InvalidPathError < Exception; end;
  class RepeatedlyCreateFolderError < Exception; end;
  class NotAssignCreatorError < Exception; end;
  class FileEmptyError < Exception; end;

  class RootDir
    def self.media_resources
      MediaResource.root_res
    end
  end

  include MediaShare::MediaResourceMethods
  include PublicResource::MediaResourceMethods

  # -------------- 这段需要放在最后，否则因为类加载顺序，会有警告信息
  # 设置全文索引字段
  define_index do
    # fields
    indexes name, :sortable => true
    indexes creator_id
    indexes is_removed
    
    # attributes
    has created_at, updated_at

    set_property :delta => true
  end
end
