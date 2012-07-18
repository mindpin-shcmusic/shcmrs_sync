class VideoUtil

  def self.screenshot(origin_path,screenshot_dir,screenshot_count=10)
    movie_info = FfmpegMovieInfo.new(origin_path)
    if !movie_info.valid?
      self.record_encode_fail_log(origin_path)
      return false
    end

    timestamps = movie_info.screenshot_timestamps

    timestamps.each_with_index do |timestamp,index|
      screenshot_path = File.join(screenshot_dir,"screenshot_#{index+1}.jpg")
      encode_command = "ffmpeg -ss #{timestamp} -i '#{origin_path}' -r 1 -vframes 1 -an -f mjpeg  -y '#{screenshot_path}'" 

      res = `#{encode_command}; echo $?`
      status = res.gsub("\n","").to_i
      if 0 != status
        self.record_encode_fail_log(origin_path)
        return false
      end
    end

  end

  def self.encode_to_flv(origin_path,flv_path)
    movie_info = FfmpegMovieInfo.new(origin_path)
    if !movie_info.valid?
      self.record_encode_fail_log(origin_path)
      return false
    end

    fps = movie_info.fps
    size = movie_info.resolution
    video_bitrate = movie_info.video_bitrate
    
    encode_command = "ffmpeg -i '#{origin_path}' -ar 44100 -ab 128k -b:v #{video_bitrate} -s #{size} -r #{fps} -y '#{flv_path}'" 
    
    res = `#{encode_command}; echo $?`
    status = res.gsub("\n","").to_i
    if 0 == status
      `yamdi -i '#{flv_path}' -o '#{flv_path}.tmp'`
      `rm '#{flv_path}'`
      `mv '#{flv_path}.tmp' '#{flv_path}'`
      return true
    else
      self.record_encode_fail_log(origin_path)
      return false
    end
  end

  def self.record_encode_fail_log(origin_path)
    File.open(File.join(Rails.root,"log/encode_fail.log"),"a") do |f|
      f << "file #{origin_path} encode fail"
      f << "\n"
    end
  end
  
end