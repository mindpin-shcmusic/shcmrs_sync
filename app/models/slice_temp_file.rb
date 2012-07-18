class SliceTempFile < ActiveRecord::Base
  belongs_to :creator, :class_name => "User"

  validates :creator_id, 
            :entry_file_name, 
            :real_file_name, 
            :entry_file_size, 
            :saved_size, 
            :presence => true

  before_validation(:on => :create) do |slice_temp_file|
    slice_temp_file.saved_size = 0
  end

  # 如果找到实例就返回
  # 如果找不到就创建一个新的并返回
  def self.find_or_create(file_name,file_size, creator)
    self.get(file_name, file_size, creator) ||
    self.create(
      :real_file_name  => file_name,
      :entry_file_name => get_randstr_filename(file_name),
      :entry_file_size => file_size,
      :creator         => creator
    )
  end
  
  def self.get(file_name,file_size,creator)
    self.where(
      :real_file_name  => file_name,
      :entry_file_size => file_size,
      :creator_id      => creator.id
    ).first
  end

  # TODO 重构
  # 保存文件片段
  def save_new_blob(file_blob)
    return if is_complete_upload?
    # 保存文件片段
    FileUtils.mv(file_blob.path,next_blob_path)
    # 记录保存进度
    self.saved_size += file_blob.size
    self.save
  end

  def get_merged_file
    if !merged?
      merge_slice_files
    end
    File.new(file_path, 'r')
  end

  def remove_files
    FileUtils.rm_r(blob_dir)
  end

  def build_file_entity
    file_entity = FileEntity.create(:merged => false)
    MergeSliceTempFileResqueQueue.enqueue(self.id, file_entity.id)
    file_entity
  end

  private

  def next_blob_path
    File.join(blob_dir, "blob.#{self.saved_size}")
  end

  # 所有文件片段是否全部上传完毕
  def is_complete_upload?
    self.saved_size >= self.entry_file_size
  end

  # 当前 slice_temp_file 的 文件片段的存放路径
  def blob_dir
    dir = File.join(R::SLICE_TEMP_FILE_ATTACHED_DIR, self.id.to_s)
    FileUtils.mkdir_p(dir)
    dir
  end

  # TODO 重构
  def merge_slice_files
    # 合并文件片段
    File.open(file_path, 'w') { |f|
      Dir[File.join(blob_dir, 'blob.*')].sort { |a, b|
        a.split('.')[-1].to_i <=> b.split('.')[-1].to_i
      }.each { |blob_path|
        File.open(blob_path, 'r') { |blob_f| f << blob_f.read }
      }
    }
    self.merged = true
    self.save
  end

  # 合并后的 slice_temp_file 文件的存放的位置
  def file_path 
    File.join(blob_dir, self.entry_file_name)
  end
end

