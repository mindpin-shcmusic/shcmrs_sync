class MediaResourcesController < ApplicationController
  def index
    # @media_resources = MediaResource.where(:dir_id => 0, :creator_id => current_user.id)
    @media_resources = current_user.media_resources.root_res

    @file_entity = FileEntity.new

    @current_dir = "/"
  end

  def file
    @file_entity = FileEntity.new

    resource_path = URI.decode(request.fullpath).sub('/file', '')
    @current_dir = resource_path

    @paths = resource_path.split(/\//)

    @media_resources = MediaResource.get(current_user, resource_path).media_resources

    render :action => "index"
  end


  def create_folder
    matched = params[:folder].match(/^([A-Za-z0-9一-龥\-\_\.]+)$/)
    if matched
      resource_path = params[:current_dir] + "/" + params[:folder]
      resource_path = resource_path.gsub("//", "/")
      MediaResource.create_folder(current_user, resource_path)

      @media_resources = MediaResource.all
    else
      flash[:error] = "非法文件目录"
    end

    redirect_to :back
  end

  def destroy
    resource_path = URI.decode(request.fullpath).sub('/file', '')
    media_resource = MediaResource.get(current_user, resource_path)
    media_resource.remove

    redirect_to :back
  end

end
