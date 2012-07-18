# VVERBOSE=1 INTERVAL=1 QUEUE=merge_slice_temp_file_resque_queue RAILS_ENV=development rake environment resque:work
class MergeSliceTempFileResqueQueue
  QUEUE_NAME = :merge_slice_temp_file_resque_queue
  @queue = QUEUE_NAME 
  
  def self.enqueue(slice_temp_file_id, file_entity_id)
    Resque.enqueue(MergeSliceTempFileResqueQueue, slice_temp_file_id, file_entity_id)
  end
  
  def self.perform(slice_temp_file_id, file_entity_id)
    slice_temp_file = SliceTempFile.find(slice_temp_file_id)
    file = slice_temp_file.get_merged_file

    file_entity = FileEntity.find(file_entity_id)
    file_entity.attach = file
    file_entity.merged = true
    file_entity.save

    slice_temp_file.remove_files
    slice_temp_file.destroy
    
    if file_entity.is_video?
      FileEntityVideoEncodeResqueQueue.enqueue(file_entity_id)
    end
  rescue Exception => ex
    p ex.message
    puts ex.backtrace*"\n"
  end
end