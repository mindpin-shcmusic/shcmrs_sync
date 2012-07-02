class MediaFile < ActiveRecord::Base
  has_many   :file_entities

  belongs_to :media_folder
end
