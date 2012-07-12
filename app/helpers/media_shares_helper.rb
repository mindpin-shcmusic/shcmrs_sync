module MediaSharesHelper
  def shared_time(user, media_resource)
    media_resource = media_resource.toppest_resource(media_resource)
    media_share = MediaShare.where(:receiver_id => user.id, :media_resource_id => media_resource.id).first
    media_share.created_at
  end
end
