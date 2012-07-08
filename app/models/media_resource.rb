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

  def is_file?
    !is_dir?
  end

  # 根据传入的资源路径字符串，查找一个资源对象
  # 传入的路径类似 /foo/bar/hello/test.txt
  # 或者 /foo/bar/hello/world
  # 找到的资源对象，可能是一个文件资源，也可能是一个文件夹资源
  def self.get(resource_path)
    names = self.split_path(resource_path)

    collect = self.root_res
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

  # 根据传入的资源路径字符串以及文件对象，创建一个文件资源
  # 传入的路径类似 /hello/test.txt
  # 创建文件资源的过程中，关联创建文件夹资源
  def self.put(resource_path, file)
    with_exclusive_scope do
      file_name = self.split_path(resource_path)[-1]
      dir_names = self.split_path(resource_path)[0...-1] # 只创建到上层目录

      collect = _mkdirs_by_names(dir_names).media_resources

      resource = collect.find_or_initialize_by_name(file_name)
      resource._remove_children!
      resource.update_attributes(
        :is_dir => false,
        :is_removed => false,
        :file_entity => FileEntity.new(
          :attach => file,
          :original_file_name => file_name
        )
      )
    end
  end

  def self.create_folder(resource_path)
    raise RepeatedlyCreateFolderError if !self.get(resource_path).blank?

    with_exclusive_scope do
      dir_names = self.split_path(resource_path)
      return _mkdirs_by_names(dir_names)
    end
  rescue InvalidPathError
    return nil
  end

  def remove
    self._remove_children!

    self.update_attributes :is_removed   => true,
                           :fileops_time => Time.now
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
    def self.split_path(resource_path) 
      raise InvalidPathError if resource_path.blank?
      raise InvalidPathError if resource_path[0...1] != '/'
      raise InvalidPathError if resource_path == '/'
      raise InvalidPathError if resource_path.match /\/{2,}/
      raise InvalidPathError if resource_path.include?('\\')

      resource_path.sub('/', '').split('/')
    end

  public

    def self._mkdirs_by_names(dir_names)
      collect = MediaResource.root_res
      dir_resource = MediaResource::RootDir

      dir_names.each {|dir_name|
        dir_resource = collect.find_or_create_by_name(dir_name)
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

  class RootDir
    def self.media_resources
      MediaResource.root_res
    end
  end
end
