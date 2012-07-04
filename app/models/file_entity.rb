class FileEntity < ActiveRecord::Base
  has_many :media_resources

  has_attached_file :attach

  def self.get_or_greate_by_file_md5(file)
    md5 = Digest::MD5.file(file).to_s

    entity = find_by_md5 md5
    if entity
      return entity
    end

    file_name = File.basename(file.path)

    entity = FileEntity.create :attach             => file,
                               :original_file_name => file_name,
                               :md5                => md5
  end
end
