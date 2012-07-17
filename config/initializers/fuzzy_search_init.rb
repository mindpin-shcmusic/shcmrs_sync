redis = Redis.new
redis.select(4)
store = Redis::Namespace.new 'shc:redis_search', :redis => redis

Redis::Search.configure do |config|
  config.redis = store
  config.complete_max_length = 32
  config.pinyin_match = true
end

User.new
