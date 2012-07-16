class RedisQueue < RedisDatabase
  def self.instance
    @@instance ||= self.get_db_instance(RedisDatabase::QUEUE_DB)
  end
end
