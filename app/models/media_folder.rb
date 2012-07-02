class MediaFolder < ActiveRecord::Base
  has_many   :media_files

  has_many   :media_folders
  belongs_to :media_folder

  validate do |folder|
    valid = case folder.media_folder_id
            when 0
              true
            else
              MediaFile.exists?(folder.media_folder_id)
            end

    errors.add(:base, 'olala') unless valid
  end
end
