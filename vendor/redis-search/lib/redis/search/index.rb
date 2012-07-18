class Redis
  module Search
    class Index
      attr_accessor :type, :title, :id,:score, :aliases, :exts, :condition_fields, :prefix_index_enable, :initial
      def initialize(options = {})
        # default data
        self.condition_fields = []
        self.exts = []
        self.aliases = []
        self.prefix_index_enable = false
        self.initial = self.class.split_initial options[:title]
        # set attributes value from params
        options.keys.each do |k|
          eval("self.#{k} = options[k]")
        end
        self.aliases << self.title
        self.aliases.uniq!
      end
      
      def save
        return if self.title.blank?
        data = {:title => self.title, :id => self.id, :type => self.type}
        self.exts.each do |f|
          data[f[0]] = f[1]
        end

        # 将原始数据存入 hashes
        res = Redis::Search.config.redis.hset('User', self.id, data.to_json)
        
        # 将目前的编号保存到条件(conditions)字段所创立的索引上面
        self.condition_fields.each do |field|
          Redis::Search.config.redis.sadd(Search.mk_condition_key(self.type,field,data[field.to_sym]), self.id)
        end
        
        # score for search sort
        Redis::Search.config.redis.set(Search.mk_score_key(self.type,self.id),self.score)
        
        # 保存 sets 索引，以分词的单词为key，用于后面搜索，里面存储 ids
        self.aliases.each do |val|
          words = Search::Index.split_words_for_index(val)
          return if words.blank?
          words.each do |word|
            Redis::Search.config.redis.sadd(Search.mk_sets_key(self.type,word), self.id)
          end
        end  
        
        # 建立前缀索引
        save_initial_prefix_index
        save_prefix_index if prefix_index_enable
      end
      
      def self.remove(options = {})
        type = options[:type]
        Redis::Search.config.redis.hdel(type,options[:id])
        words = Search::Index.split_words_for_index(options[:title])
        words.each do |word|
          Redis::Search.config.redis.srem(Search.mk_sets_key(type,word), options[:id])
          Redis::Search.config.redis.del(Search.mk_score_key(type,options[:id]))
        end
        
        # remove set for prefix index key
        Redis::Search.config.redis.srem(Search.mk_sets_key(type,options[:title]),options[:id])
      end
      
      private

        def self.split_initial(text)
          Pinyin.t(text).split(' ').map(&:first).reduce(:+)
        end

        def self.split_words_for_index(title)
          words = Search.split(title)
          if Search.config.pinyin_match
            # covert Chinese to pinyin to as an index
            words += Search.split_pinyin(title)
          end
          words.uniq
        end

        def save_initial_prefix_index
          Redis::Search.config.redis.sadd(Search.mk_sets_key(self.type, self.initial), self.id)

          key = Search.mk_complete_key(self.type)
          (1..(self.initial.length)).each do |l|
            prefix = self.initial[0...l]
            Redis::Search.config.redis.zadd(key, 0, prefix)
          end
          Redis::Search.config.redis.zadd(key, 0, self.initial + "*")
        end

        def save_prefix_index
          self.aliases.each do |val|
            words = []
            words << val.downcase
            Redis::Search.config.redis.sadd(Search.mk_sets_key(self.type,val), self.id)
            if Search.config.pinyin_match
              pinyin = Pinyin.t(val.downcase,'')
              words << pinyin
              Redis::Search.config.redis.sadd(Search.mk_sets_key(self.type,pinyin), self.id)
            end
            
            words.each do |word|
              key = Search.mk_complete_key(self.type)
              (1..(word.length)).each do |l|
                prefix = word[0...l]
                Redis::Search.config.redis.zadd(key, 0, prefix)
              end
              Redis::Search.config.redis.zadd(key, 0, word + "*")
            end
          end
        end
    end
  end
end
