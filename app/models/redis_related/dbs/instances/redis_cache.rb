class RedisCache < RedisDatabase
  def self.instance
    @@instance ||= self.get_db_instance(RedisDatabase::CACHE_DB)
  end
end