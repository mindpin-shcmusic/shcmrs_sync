# VVERBOSE=1 INTERVAL=1 QUEUE=file_entity_video_encode_resque_queue RAILS_ENV=development rake environment resque:work
class FileEntityVideoEncodeResqueQueue
  QUEUE_NAME = :file_entity_video_encode_resque_queue
  @queue = QUEUE_NAME 
  
  def self.enqueue(file_entity_id)
    Resque.enqueue(FileEntityVideoEncodeResqueQueue, file_entity_id)
  end
  
  def self.perform(file_entity_id)
    file_entity = FileEntity.find(file_entity_id)
    origin_file_path = file_entity.attach.path
    flv_path = file_entity.attach_flv_path
    encode_is_success = VideoUtil.encode_to_flv(origin_file_path,flv_path)
    VideoUtil.screenshot(origin_file_path,File.dirname(origin_file_path))

    if encode_is_success
      file_entity.video_encode_status = FileEntity::EncodeStatus::SUCCESS
    else
      file_entity.video_encode_status = FileEntity::EncodeStatus::FAILURE
    end
    file_entity.save
  rescue Exception => ex
    p ex.message
    puts ex.backtrace*"\n"
  end
end