module RedisSearch
  module Base
    def self.included(base)
      base.send :include, Redis::Search
      base.send :extend, ClassMethods
    end

    module ClassMethods
      def complete_search(title, conditions = {})
        Redis::Search.complete self.to_s, 
                               title,
                               :conditions => conditions
      end
    end
  end

  module UserMethods
    def self.included(base)
      base.send :include, Base
      base.redis_search_index :title_field         => :name,
                              :score_field         => :id,
                              :prefix_index_enable => true
    end
  end
end