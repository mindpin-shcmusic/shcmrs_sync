class R
  ATTACHED_BASE_DIR             = "#{Rails.root}/public"

  FILE_ENTITY_ATTACHED_PATH     = "#{ATTACHED_BASE_DIR}:url"
  FILE_ENTITY_ATTACHED_URL      = "/system/:attachment/:id/:style/:filename"

  SLICE_TEMP_FILE_ATTACHED_DIR  = "#{ATTACHED_BASE_DIR}/system/slice_temp_files/"
end