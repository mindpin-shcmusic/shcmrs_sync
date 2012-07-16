class UserTipMessage < RedisTip
  include Notifying

  class << self
    def create(user, message_str)
      instance.lpush key(user), message_str
      notify_count(user)
    end

    def all(user)
      instance.lrange key(user), 0, -1
    end

    def count(user)
      instance.llen key(user)
    end

    def clear(user)
      instance.del key(user)
      notify_count(user)
    end

    def url(user)
      "/users/#{user.id}/message_list"
    end

    protected

    def key(user)
      "utm:#{user.id}"
    end

    def unread_count(user)
      count(user)
    end
  end
end
