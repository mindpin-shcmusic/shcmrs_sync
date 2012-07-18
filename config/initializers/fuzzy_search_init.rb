begin
  redis = Redis.new
  redis.select(4)
  store = Redis::Namespace.new 'shc:redis_search', :redis => redis

  Redis::Search.configure do |config|
    config.redis = store
    config.pinyin_match = true
    config.disable_rmmseg = true
  end

  User.new

rescue => e
  puts '没有安装redis，redis相关功能没有办法使用'
  puts e
end
