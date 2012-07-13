class MediaSharesController < ApplicationController
  def new
    resource_path = params[:resource_path].sub('/file', '')

    @current_dir = MediaResource.get(current_user, resource_path)

    @users = User.where("id != ?", current_user.id)

    @shared_receivers = @current_dir.shared_receivers

  end

  def create
    media_resource = MediaResource.find(params[:media_resource_id])

    MediaShare.destroy_all(:media_resource_id => media_resource.id)

    params[:receivers].each do |receiver_id|
      MediaShare.create(
        :creator => current_user,
        :receiver_id => receiver_id,
        :media_resource => media_resource
      )
    end

    redirect_to params[:resource_path].split(/\//)[0..-2].join('/')

  end

  def mine
    @received_resources = current_user.received_shared_media_resources
    UserShareTipMessage.clear current_user
  end

  # 分享给其它用户目录
  def share
    resource_path = URI.decode(request.fullpath).sub(/\/media_shares\/user\/.*\/file/, "")

    creator = User.find(params[:id])
    current_resource = MediaResource.get(creator, resource_path)

    if current_resource.is_dir?
      @current_dir = current_resource
      @media_resources = @current_dir.media_resources.web_order
    end

     p 55555
     p @media_resources
     p 7777777
    
    if current_resource.is_file?
      return send_file current_resource.attach.path
    end
  end
end
