class FileEntity < ActiveRecord::Base
  has_many :media_resources

  has_attached_file :attach,
    :path => R::FILE_ENTITY_ATTACHED_PATH,
    :url  => R::FILE_ENTITY_ATTACHED_URL

  def self.get_or_greate_by_file_md5(file)
    md5 = Digest::MD5.file(file).to_s

    entity = find_by_md5 md5
    if entity
      return entity
    end

    entity = FileEntity.create :attach => file,
                               :md5    => md5
  end


end
