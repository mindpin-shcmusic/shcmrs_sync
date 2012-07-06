module Paperclip
  class << self
    def logger
      Mongoid.logger || Rails.logger
    end
  end
end
