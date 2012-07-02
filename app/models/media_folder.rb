class MediaFolder < ActiveRecord::Base
  has_many   :media_files

  has_many   :media_folders
  belongs_to :media_folder
end
