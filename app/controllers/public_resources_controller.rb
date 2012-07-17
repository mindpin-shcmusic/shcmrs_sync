class PublicResourcesController < ApplicationController
  # 公共资源列表
  def index
    @shared_resources = current_user.shared_public_resources

    @uploaded_resources = current_user.uploaded_public_resources

  end

  # 分享到公共资源
  def share
    resource_id = params[:resource_id]
    current_resource = MediaResource.find(resource_id)

    public_resource_id = current_resource.share_public

    render :text => public_resource_id

  end

  # 上传到公共资源 
  def upload
    PublicResource.upload_by_user(current_user, params[:file])

    redirect_to :back
  end


  
  def index_file
    id = params[:file_entity_id]

    file_entity = FileEntity.find(id)
    return send_file file_entity.attach.path
  end

  # 目录下面的目录
  def dir
    resource_path = URI.decode(request.fullpath).sub(/\/public_resources\/user\/.*\/file/, "")

    creator = User.find(params[:id])
    current_resource = MediaResource.get(creator, resource_path)

    if current_resource.is_dir?
      @current_dir = current_resource
      @media_resources = @current_dir.media_resources.web_order
    end
    
    if current_resource.is_file?
      return send_file current_resource.attach.path
    end
  end


  # 搜索公共资源
  def search
    @keyword = params[:keyword]
    @public_resources = PublicResource.search(@keyword, 
      :conditions => {:creator_id => current_user.id}, 
      :page => params[:page], :per_page => 20)

  end


end
