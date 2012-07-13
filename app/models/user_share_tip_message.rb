class UserShareTipMessage < UserTipMessage
  class << self
    def url(user)
      '/media_shares/mine'
    end

    protected

    def key(user)
      "utm:mshare:#{user.id}"
    end
  end
end
