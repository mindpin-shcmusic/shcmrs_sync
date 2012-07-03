class FileEntity < ActiveRecord::Base
  belongs_to :media_resource
  has_attached_file :attach
end
