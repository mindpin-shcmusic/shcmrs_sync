module FuzzySearch
  def self.included(base)
    base.send :include,
              Redis::Search

    base.send :extend,
              ClassMethods
  end

  module ClassMethods
    def complete_search(title, conditions = {})
      Redis::Search.complete self.to_s,
                             title,
                             :conditions => conditions
    end

    protected

    def fuzzy_index(title, score, prefix_index = true)
      redis_search_index :title_field         => title,
                         :score_field         => score,
                         :prefix_index_enable => prefix_index
    end
  end
end
