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

  def my
    @received_resources = current_user.received_shared_media_resources
  end

  # 分享给其它用户目录
  def share
    pattern = "/media_shares/user/#{current_user.id}/file"
    resource_path = URI.decode(request.fullpath).sub(pattern, "")

    p 555555555555555555555555555555
    p URI.decode(request.fullpath)
    p resource_path
    p 222222222222222222222222222

    current_resource = MediaResource.get(current_user, resource_path)

    if current_resource.is_dir?
      @current_dir = current_resource
      @media_resources = @current_dir.media_resources.web_order
    end
    
    if current_resource.is_file?
      return send_file current_resource.attach.path
    end
  end
end
