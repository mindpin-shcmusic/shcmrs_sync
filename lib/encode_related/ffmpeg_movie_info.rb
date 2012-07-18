require 'open3'

class FfmpegMovieInfo
  def initialize(path)
    @movie = FFMPEG::Movie.new(path)
  end

  def fps
    @movie.frame_rate || 25
  end

  def valid?
    @movie.valid?
  end

  def video_bitrate
   bitrate = @movie.video_bitrate
   bitrate = bitrate.nil? ? @movie.bitrate : bitrate
   "#{bitrate}k"
  end

  def resolution
    @movie.resolution
  end

  def duration
    @movie.duration.to_i
  end

  def raw_duration
    _second_to_time(@movie.duration.to_i)
  end

  def screenshot_timestamps(count=10)
    timestamps = []
    step = duration/(count+1)
    0.upto(count-1){|index|timestamps << (index+1)*step}
    timestamps.map!{|timestamp|_second_to_time(timestamp)}
  end

  private
  def _second_to_time(second)
    hour = second/60/60
    minute = second/60-hour*60
    second = second-minute*60-hour*60*60
    "#{sprintf("%.2d",hour)}:#{sprintf("%.2d",minute)}:#{sprintf("%.2d",second)}"
  end
end