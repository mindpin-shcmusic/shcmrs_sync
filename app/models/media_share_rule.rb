class MediaShareRule < ActiveRecord::Base
  belongs_to :media_resource
  belongs_to :creator

  def build_expression(options = {:users => [], :courses => [], :teams => []})
    self.expression = options.to_json
  end

  def expression
    JSON.parse read_attribute(:expression),
               :symbolize_names => true
  end

  def get_receiver_ids
    direct_ids = expression[:users]
    course_user_ids = expression[:courses].map {|cid|
      Course.find cid
    }.map {|course| [course.teacher, course.students]}.flatten.map(&:user_id)
    team_user_ids = expression[:teams].map {|tid|
      Team.find tid
    }.map {|team| [team.teacher, team.students]}.flatten.map(&:user_id)

    user_ids = (direct_ids + course_user_ids + team_user_ids).flatten.compact.uniq

    user_ids.delete(self.media_resource.creator)
    user_ids
  end

  def get_receivers
    User.find get_receiver_ids
  end

  def build_share
    get_receivers.each {|user|
      MediaShare.create :creator        => self.media_resource.creator,
                        :media_resource => self.media_resource,
                        :receiver       => user
    }
  end

  module UserMethods
    def self.included(base)
      base.has_many :media_share_rules,
                    :foreign_key => 'creator_id'
    end
  end
end