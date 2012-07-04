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

  # 根据传入的资源路径字符串，查找一个资源对象
  # 传入的路径类似 /hello/test.txt
  # 或者 /hello/world
  # 找到的资源对象，可能是一个文件资源，也可能是一个文件夹资源
  def self.get_by_path(resource_path)
    names = resource_path.sub('/', '').split('/')

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
    file_name = resource_path.sub('/', '').split('/')[-1]

    # 传入的是 北极熊/企鹅/西瓜.jpg
    # 则
    # file_name: "西瓜.jpg"



    collect = self._mkdirs(resource_path)

    resource = collect.find_or_initialize_by_name_and_is_dir(file_name, false)

    resource.file_entity = FileEntity.new({
      :attach => file,
      :original_file_name => file_name
    })

    resource.save

  end

  # 逐层创建文件夹资源（如果不存在），并返回最后一个文件夹资源 或者 MediaResource 类对象
  def self._mkdirs(resource_path)
    dir_names = resource_path.sub('/', '').split('/')[0...-1]

    # 传入的是 北极熊/企鹅/西瓜.jpg
    # 则
    # dir_names: ["北极熊", "企鹅"]

    # 逐层地创建目录资源
    collect = MediaResource

    dir_names.each {|dir_name|
      dir_resource = collect.find_or_create_by_name_and_is_dir(dir_name, true)
      collect = dir_resource.media_resources
    }

    return collect
  end

  # ------------
  # 下面的代码还没动

  def metadata(options = {:list => true})
    self.is_dir ? dir_metadata(options) : file_metadata
  end

  def attach
    file_entity.attach
  end

  def path resource = self, input_array = []
    path_ary = input_array
    if resource.dir_id == 0
      path_ary << self
      return path_ary.map {|r| r.name}.join('/').insert(0, '/')
    end
    parent = MediaResource.find(resource.dir_id)

    path_ary.unshift parent
    path parent, path_ary
  end

  private

  def file_metadata
    base_metadata.merge({
      :rev       => randstr(8),
      :modified  => updated_at,
      :mime_type => attach.content_type
    })
  end

  def dir_metadata(options = {})
    dir_id = self.dir_id

    hash = base_metadata

    # 如果true:
    # 当前目录下的子目录不显示contents
    # 如果false：
    # 当前目录下的子目录示contents
    hash[:contents] = media_resources.map do |r|
      if r.is_dir
        options[:list] ? r.metadata(:list => true) : r.send(:base_metadata)
      else
        r.metadata
      end
    end

    hash
  end

  def base_metadata
    {
      :bytes    => is_dir ? 0 : attach.size,
      :path     => path,
      :is_dir   => is_dir
    }
  end
end
