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

  ##################
  class EncodeStatus
    SUCCESS  = "SUCCESS"
    FAILURE  = "FAILURE"
  end

  def attach_flv_path
    "#{self.attach.path}.flv"
  end

  def attach_flv_url
    self.attach.url.gsub(/\?.*/,".flv")
  end

  def is_video?
    :video == self.content_kind
  end

  CONTENT_TYPES = {
    :video    => [
        'avi', 'rm',  'rmvb', 'mp4', 
        'ogv', 'm4v', 'flv', 'mpeg',
        '3gp'
      ].map{|x| file_content_type(x)}.uniq - ['application/octet-stream'],
    :audio    => [
        'mp3', 'wma', 'm4a',  'wav', 
        'ogg'
      ].map{|x| file_content_type(x)}.uniq,
    :image    => [
        'jpg', 'jpeg', 'bmp', 'png', 
        'png', 'svg',  'tif', 'gif'
      ].map{|x| file_content_type(x)}.uniq,
    :document => [
        'pdf', 'xls', 'doc', 'ppt'
      ].map{|x| file_content_type(x)}.uniq
  }

  def content_kind
    case self.attach_content_type
    when *CONTENT_TYPES[:video]
      :video
    when *CONTENT_TYPES[:audio]
      :audio
    when *CONTENT_TYPES[:image]
      :image
    when *CONTENT_TYPES[:document]
      :document
    end
  end




end
