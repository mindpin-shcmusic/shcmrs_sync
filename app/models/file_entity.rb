class FileEntity < ActiveRecord::Base
  has_many :media_resources

  has_attached_file :attach
end
