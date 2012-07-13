class RedisTip < RedisDatabase
  def self.instance
    @@instance ||= self.get_db_instance(RedisDatabase::TIP_DB)
  end
end
