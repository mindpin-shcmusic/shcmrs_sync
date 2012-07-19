ROOT_DIR = File.expand_path('../../', __FILE__)

# worker 数量
worker_processes 3

# 日志位置
# stderr_path("#{ROOT_DIR}/log/unicorn-shcmrs_sync-error.log")
# stdout_path("#{ROOT_DIR}/log/unicorn-shcmrs_sync.log")

# 加载 超时设置 监听
preload_app true
timeout 60
listen "9527"

pid_file_name = "#{ROOT_DIR}/tmp/pids/unicorn-pin-edu-sns.pid"
pid pid_file_name

# REE GC
if GC.respond_to?(:copy_on_write_friendly=)
  GC.copy_on_write_friendly = true
end

before_fork do |server, worker|
  old_pid = pid_file_name + '.oldbin'
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # ...
    end
  end
end

after_fork do |server, worker|
  ActiveRecord::Base.establish_connection
end